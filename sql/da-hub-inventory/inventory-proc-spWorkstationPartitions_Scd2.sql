use DaHubInventory
go


drop proc if exists dbo.spWorkstationPartitions_Scd2
go
create proc dbo.spWorkstationPartitions_Scd2
	@partitions dbo.tvpWorkstationPartitions readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate
			if exists (
				select ComputerName, PartitionNumber
				from @partitions
				where ComputerName is not null and PartitionNumber is not null
				group by ComputerName, PartitionNumber
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, PartitionNumber found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @partitions where ComputerName is null or PartitionNumber is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and ServicName canot be NULL',1;
			end;

			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				PartitionNumber, 
				convert(int,DiskNumber) DiskNumber, 

				convert(bit,IsBoot) IsBoot, 
				convert(bit,IsHidden) IsHidden, 
				convert(bit,IsSystem) IsSystem, 
				convert(bit,IsReadOnly) IsReadOnly, 
				convert(bit,IsOffline) IsOffline, 
				convert(bit,IsActive) IsActive, 

				convert(varchar(2),DriveLetter) DriveLetter, 
				convert(float,PartitionSizeGb) PartitionSizeGb, 

				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(PartitionNumber,''))) ,
								case when DiskNumber = 1 then '1' else '0' end, 
								case when convert(bit,IsBoot) = 1 then '1' else '0' end, 
								case when convert(bit,IsHidden) = 1 then '1' else '0' end, 
								case when convert(bit,IsSystem) = 1 then '1' else '0' end, 
								case when convert(bit,IsReadOnly) = 1 then '1' else '0' end, 
								case when convert(bit,IsOffline) = 1 then '1' else '0' end, 
								case when convert(bit,IsActive) = 1 then '1' else '0' end, 
								lower(convert(varchar,isnull(DriveLetter,''))), 
								lower(convert(varchar,isnull(PartitionSizeGb,'')))
							)
						)
			into #sourceHashedParameter
			from @partitions;





			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, partition-number) tuple is current
			*/
			declare @reset int = 0;
			if @reset = 1
			begin
				-- Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
				begin try
					begin transaction;

					update wp
					set wp.IsCurrent = 0,
						wp.ExpiryDate = null,
						wp.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
						RowHash = hashbytes(
									'sha2_256', 
									concat(
										lower(convert(varchar,isnull(ComputerName,''))), 
										lower(convert(varchar,isnull(PartitionNumber,''))) ,
										case when DiskNumber = 1 then '1' else '0' end, 
										case when convert(bit,IsBoot) = 1 then '1' else '0' end, 
										case when convert(bit,IsHidden) = 1 then '1' else '0' end, 
										case when convert(bit,IsSystem) = 1 then '1' else '0' end, 
										case when convert(bit,IsReadOnly) = 1 then '1' else '0' end, 
										case when convert(bit,IsOffline) = 1 then '1' else '0' end, 
										case when convert(bit,IsActive) = 1 then '1' else '0' end, 
										lower(convert(varchar,isnull(DriveLetter,''))), 
										lower(convert(varchar,isnull(PartitionSizeGb,'')))
									)
								)
					from dbo.WorkstationPartition wp;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & partition-number name tuple
				begin try
					begin transaction;

					;with cte as (
						select wp.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, PartitionNumber order by PartitionScanSuccessDate desc) 
						from dbo.WorkstationPartition wp
				
					) 
						update c	
							set c.IsCurrent = 1,
								c.SlowlyChangingDimensionReason = 'manual-step-0.2-activate-lastest-row->IsCurrent=1'
						from cte c
						where RowNum = 1;

					commit transaction;

				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & partition-number name tuple 
				begin try
					begin transaction;
						;with cte as (
							select wp.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, PartitionNumber order by PartitionScanSuccessDate desc) 
							from dbo.WorkstationPartition wp
				
						) 
							update c	
								set c.IsCurrent = 0,
									c.ExpiryDate = convert(date,getdate()),
									c.SlowlyChangingDimensionReason = 'manual-step-0.3-deactivate-old-record->add-expiry-date->IsCurrent=0-&&-expiration-date'
							from cte c
							where c.IsCurrent != 1

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;



				-- count
				select SlowlyChangingDimensionReason, count(*) 
				from dbo.WorkstationPartition
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-partition-number-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0'
				from dbo.WorkstationPartition dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.PartitionNumber = dst.PartitionNumber
						)
				;

				
				-- scenario-2:destination-is-null->new-partition-number-found->insert
				insert into dbo.WorkstationPartition(
						ComputerName,PartitionNumber,DiskNumber,IsBoot,IsHidden,IsSystem,IsReadOnly,IsOffline,IsActive,DriveLetter,PartitionSizeGb,
						PartitionScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,PartitionNumber,DiskNumber,IsBoot,IsHidden,IsSystem,IsReadOnly,IsOffline,IsActive,DriveLetter,PartitionSizeGb,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-partition-number-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationPartition dst
							where dst.ComputerName = src.ComputerName
								and dst.PartitionNumber = src.PartitionNumber
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set PartitionScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationPartition dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.PartitionNumber = dst.PartitionNumber and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> partition-number drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationPartition dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.PartitionNumber = dst.PartitionNumber 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationPartition(
						ComputerName,PartitionNumber,DiskNumber,IsBoot,IsHidden,IsSystem,IsReadOnly,IsOffline,IsActive,DriveLetter,PartitionSizeGb,
						PartitionScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,PartitionNumber,DiskNumber,IsBoot,IsHidden,IsSystem,IsReadOnly,IsOffline,IsActive,DriveLetter,PartitionSizeGb,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationPartition dst
							where dst.ComputerName = src.ComputerName
								and dst.PartitionNumber = src.PartitionNumber
								and dst.IsCurrent = 1
						)
				;

				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;
			

				commit transaction;
			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;
			;


	end try
	begin catch
		if @@trancount > 0 rollback transaction;
		throw;
	end catch

end

go
