use DaHubInventory
go


drop proc if exists dbo.spWorkstationMonitors_Scd2
go
create proc dbo.spWorkstationMonitors_Scd2
	@monitors dbo.tvpWorkstationMonitors readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate 
			if exists (
				select ComputerName, MonitorSerial
				from @monitors
				where ComputerName is not null and MonitorSerial is not null
				group by ComputerName, MonitorSerial
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, monitor serial found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @monitors where ComputerName is null)
			begin;
				throw 51001, 'Custom exception: ComputerName cannot be null',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				isnull(trim(MonitorManufacturer),'') MonitorManufacturer, 
				isnull(trim(MonitorName),'') MonitorName, 
				isnull(trim(MonitorSerial),'') MonitorSerial, 
				isnull(trim(MonitorYear),'') MonitorYear, 
				isnull(trim(MonitorCaption),'') MonitorCaption, 
				isnull(trim(MonitorResolution),'') MonitorResolution, 
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(MonitorManufacturer,''))) ,
								lower(convert(varchar,isnull(MonitorName,''))), 
								lower(convert(varchar,isnull(MonitorSerial,''))),
								lower(convert(varchar,isnull(MonitorYear,''))),
								lower(convert(varchar,isnull(MonitorCaption,''))),
								lower(convert(varchar,isnull(MonitorResolution,'')))
							)
						)
			into #sourceHashedParameter
			from @monitors;





			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, monitor serial) tuple is current
			*/
			declare @reset int = 0;
			if @reset = 1
			begin
				-- Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
				begin try
					begin transaction;

					update wm
					set wm.IsCurrent = 0,
						wm.ExpiryDate = null,
						wm.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
						RowHash = hashbytes(
									'sha2_256', 
									concat(
										lower(convert(varchar,isnull(ComputerName,''))), 
										lower(convert(varchar,isnull(MonitorManufacturer,''))) ,
										lower(convert(varchar,isnull(MonitorName,''))), 
										lower(convert(varchar,isnull(MonitorSerial,''))),
										lower(convert(varchar,isnull(MonitorYear,''))),
										lower(convert(varchar,isnull(MonitorCaption,''))),
										lower(convert(varchar,isnull(MonitorResolution,'')))
									)
								)
					from dbo.WorkstationMonitors wm;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & monitor-serial tuple
				begin try
					begin transaction;

					;with cte as (
						select wm.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, MonitorSerial order by MonitorScanSuccessDate desc) 
						from dbo.WorkstationMonitors wm
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & monitor-serial name tuple 
				begin try
					begin transaction;
						;with cte as (
							select wm.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, MonitorSerial order by MonitorScanSuccessDate desc) 
							from dbo.WorkstationMonitors wm
				
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
				from dbo.WorkstationMonitors
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->monitor-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-moitor-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> monitor status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;


			begin try 
				begin transaction;

				-- scenario-1:source-is-null->monitor-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->monitor-removed->set-IsCurrent=0'
				from dbo.WorkstationMonitors dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.MonitorSerial = dst.MonitorSerial
						)
				;

				-- scenario-2:destination-is-null->new-monitor-found->insert
				insert into dbo.WorkstationMonitors(
						ComputerName,MonitorManufacturer,MonitorName,MonitorSerial,MonitorYear,MonitorCaption,MonitorResolution,
						MonitorScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,MonitorManufacturer,MonitorName,MonitorSerial,MonitorYear,MonitorCaption,MonitorResolution,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-monitor-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationMonitors dst
							where dst.ComputerName = src.ComputerName
								and dst.MonitorSerial = src.MonitorSerial
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set MonitorScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationMonitors dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.MonitorSerial = dst.MonitorSerial and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> monitor status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> monitor drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationMonitors dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.MonitorSerial = dst.MonitorSerial 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationMonitors(
						ComputerName,MonitorManufacturer,MonitorName,MonitorSerial,MonitorYear,MonitorCaption,MonitorResolution,
						MonitorScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName,MonitorManufacturer,MonitorName,MonitorSerial,MonitorYear,MonitorCaption,MonitorResolution,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationMonitors dst
							where dst.ComputerName = src.ComputerName
								and dst.MonitorSerial = src.MonitorSerial
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
