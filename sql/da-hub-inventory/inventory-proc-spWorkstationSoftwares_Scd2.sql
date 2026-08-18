use DaHubInventory
go


drop proc if exists dbo.spWorkstationSoftwares_Scd2
go
create proc dbo.spWorkstationSoftwares_Scd2
	@softwares dbo.tvpWorkstationSoftwares readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try
	
			-- Guard: reject duplicate. fox it duplicate found in one computer with details slightly different
			;

			-- Guard: reject null
			if exists (select 1 from @softwares where ComputerName is null or SoftwareName is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and ServicName canot be NULL',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				SoftwareName, 
				isnull(trim(SoftwareVendor),'') SoftwareVendor, 
				isnull(trim(SoftwareVersion),'') SoftwareVersion, 
				convert(date,SoftwareInstallDate) SoftwareInstallDate, 
				isnull(trim(SoftwareInstallLocation),'') SoftwareInstallLocation, 
				isnull(trim(SoftwareInstallSource),'') SoftwareInstallSource, 
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(SoftwareName,''))) ,
								lower(convert(varchar,isnull(SoftwareVendor,''))), 
								lower(convert(varchar,isnull(SoftwareVersion,''))),
								convert(date,SoftwareInstallDate),
								lower(convert(varchar,isnull(SoftwareInstallLocation,''))),
								lower(convert(varchar,isnull(SoftwareInstallSource,'')))
							)
						)
			into #sourceHashedParameter
			from @softwares;



			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, software) tuple is current
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
										lower(convert(varchar,isnull(SoftwareName,''))) ,
										lower(convert(varchar,isnull(SoftwareVendor,''))), 
										lower(convert(varchar,isnull(SoftwareVersion,''))),
										convert(date,SoftwareInstallDate),
										lower(convert(varchar,isnull(SoftwareInstallLocation,''))),
										lower(convert(varchar,isnull(SoftwareInstallSource,'')))
									)
								)
					from dbo.WorkstationSoftware wp;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & software name tuple
				begin try
					begin transaction;

					;with cte as (
						select ws.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, SoftwareName order by SoftwareScanSuccessDate desc) 
						from dbo.WorkstationSoftware ws
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & software name tuple 
				begin try
					begin transaction;
						;with cte as (
							select ws.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, SoftwareName order by SoftwareScanSuccessDate desc) 
							from dbo.WorkstationSoftware ws
				
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
				from dbo.WorkstationSoftware
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->software-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-software-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> software status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->software-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->software-removed->set-IsCurrent=0'
				from dbo.WorkstationSoftware dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.SoftwareName = dst.SoftwareName
						)
				;

				-- scenario-2:destination-is-null->new-software-found->insert
				insert into dbo.WorkstationSoftware(
						ComputerName,SoftwareName,SoftwareVendor,SoftwareVersion,SoftwareInstallDate,SoftwareInstallLocation,SoftwareInstallSource,
						SoftwareScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,SoftwareName,SoftwareVendor,SoftwareVersion,SoftwareInstallDate,SoftwareInstallLocation,SoftwareInstallSource,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-software-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationSoftware dst
							where dst.ComputerName = src.ComputerName
								and dst.SoftwareName = src.SoftwareName
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set SoftwareScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationSoftware dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.SoftwareName = dst.SoftwareName and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> software status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> software drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationSoftware dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.SoftwareName = dst.SoftwareName 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationSoftware(
						ComputerName,SoftwareName,SoftwareVendor,SoftwareVersion,SoftwareInstallDate,SoftwareInstallLocation,SoftwareInstallSource,
						SoftwareScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,SoftwareName,SoftwareVendor,SoftwareVersion,SoftwareInstallDate,SoftwareInstallLocation,SoftwareInstallSource,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationSoftware dst
							where dst.ComputerName = src.ComputerName
								and dst.SoftwareName = src.SoftwareName
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
