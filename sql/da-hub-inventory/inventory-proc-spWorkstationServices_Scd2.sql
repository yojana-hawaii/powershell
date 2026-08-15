use DaHubInventory
go


drop proc if exists dbo.spWorkstationServices_Scd2
go
create proc dbo.spWorkstationServices_Scd2
	@services dbo.tvpWorkstationServices readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate
			if exists (
				select ComputerName, ServiceName
				from @services
				where ComputerName is not null and ServiceName is not null
				group by ComputerName, ServiceName
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, servicename found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @services where ComputerName is null or ServiceName is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and ServicName canot be NULL',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, ServiceName, 
				isnull(trim(ServiceDisplayName),'') ServiceDisplayName,
				isnull(trim(ServiceState),'') ServiceState, 
				isnull(trim(ServiceStartMode),'') ServiceStartMode, 
				convert(bit,ServiceAcceptPause) ServiceAcceptPause, 
				convert(bit,ServiceAcceptStop) ServiceAcceptStop, 
				convert(bit,ServiceDelayedAutoStart) ServiceDelayedAutoStart,
				isnull(trim(ServiceStartName),'') ServiceStartName,
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(ServiceName,''))) ,
								lower(convert(varchar,isnull(ServiceDisplayName,''))),
								lower(convert(varchar,isnull(ServiceState,''))), 
								lower(convert(varchar,isnull(ServiceStartMode,''))),
								case when convert(bit,ServiceAcceptPause) = 1 then '1' else '0' end, 
								case when convert(bit,ServiceAcceptStop) = 1 then '1' else '0' end, 
								case when convert(bit,ServiceDelayedAutoStart) = 1 then '1' else '0' end, 
								lower(convert(varchar,isnull(ServiceStartName,'')))
							)
						)
			into #sourceHashedParameter
			from @services;
		
			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, service) tuple is current
			4. rest add expirattio  date as today
			*/
			declare @reset int = 0;
			if @reset = 1
			begin
				-- Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
				begin try
					begin transaction;

					update ws
					set ws.IsCurrent = 0,
						ws.ExpiryDate = null,
						ws.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
						RowHash = hashbytes(
									'sha2_256', 
									concat(
										lower(convert(varchar,isnull(ComputerName,''))), 
										lower(convert(varchar,isnull(ServiceName,''))),
										lower(convert(varchar,isnull(ServiceDisplayName,''))),
										lower(convert(varchar,isnull(ServiceState,''))), 
										lower(convert(varchar,isnull(ServiceStartMode,''))),
										case when ServiceAcceptPause = 1 then '1' else '0' end, 
										case when ServiceAcceptStop = 1 then '1' else '0' end, 
										case when ServiceDelayedAutoStart = 1 then '1' else '0' end, 
										lower(convert(varchar,isnull(ServiceStartName,'')))
									)
								)
					from dbo.WorkstationServices ws;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & service name tuple
				begin try
					begin transaction;

					;with cte as (
						select ws.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, ServiceName order by ServiceScanSuccessDate desc) 
						from dbo.WorkstationServices ws
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & service name tuple 
				begin try
					begin transaction;
						;with cte as (
							select ws.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, ServiceName order by ServiceScanSuccessDate desc) 
							from dbo.WorkstationServices ws
				
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


				-- step-0.4: if service scan date is older than 1 hour of newest scanned service -> means it is not longer active service.
				begin try
					begin transaction;

						update ws	
							set ws.IsCurrent = 0,
								ws.ExpiryDate = convert(date,getdate()),
								ws.SlowlyChangingDimensionReason = 'manual-step-0.4-service-scan-more-than-one-hour-of-other-services->set-IsCurrent=0-&&-expiration-date'
						from dbo.WorkstationServices ws --2026-08-13 14:22:20.110
						where ws.IsCurrent = 1
							and ws.ServiceScanSuccessDate < (
									select dateadd(hour, -1, max(mx.ServiceScanSuccessDate) )
									from dbo.WorkstationServices mx
									where ws.ComputerName = mx.ComputerName
								)

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;


				-- count
				select SlowlyChangingDimensionReason, count(*) 
				from dbo.WorkstationServices
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->service-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-service-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> service status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->service-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->service-removed->set-IsCurrent=0'
				from dbo.WorkstationServices dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.ServiceName = dst.ServiceName
						)
				;

				-- scenario-2:destination-is-null->new-service-found->insert
				insert into dbo.WorkstationServices (
						ComputerName, ServiceName, ServiceDisplayName,ServiceState, ServiceStartMode, 
						ServiceAcceptPause, ServiceAcceptStop, ServiceDelayedAutoStart,ServiceStartName,
						ServiceScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, ServiceName, ServiceDisplayName,ServiceState, ServiceStartMode, 
					ServiceAcceptPause, ServiceAcceptStop, ServiceDelayedAutoStart,ServiceStartName,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-service-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationServices dst
							where dst.ComputerName = src.ComputerName
								and dst.ServiceName = src.ServiceName
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set ServiceScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationServices dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.ServiceName = dst.ServiceName and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> service status changed
				-- step 5.1: hash no-match -> service status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> service status changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationServices dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.ServiceName = dst.ServiceName 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationServices (
						ComputerName, ServiceName, ServiceDisplayName,ServiceState, ServiceStartMode, 
						ServiceAcceptPause, ServiceAcceptStop, ServiceDelayedAutoStart,ServiceStartName,
						ServiceScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, ServiceName, ServiceDisplayName,ServiceState, ServiceStartMode, 
					ServiceAcceptPause, ServiceAcceptStop, ServiceDelayedAutoStart,ServiceStartName,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationServices dst
							where dst.ComputerName = src.ComputerName
								and dst.ServiceName = src.ServiceName
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
