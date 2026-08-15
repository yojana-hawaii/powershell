use DaHubInventory
go


drop proc if exists dbo.spWorkstationPrinters_Scd2
go
create proc dbo.spWorkstationPrinters_Scd2
	@printers dbo.tvpWorkstationPrinters readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate
			if exists (
				select ComputerName, PrinterName
				from @printers
				where ComputerName is not null and PrinterName is not null
				group by ComputerName, PrinterName
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, PrinterName found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @printers where ComputerName is null or PrinterName is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and ServicName canot be NULL',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				PrinterName, 
				convert(bit,PrinterShared) PrinterShared, 
				isnull(trim(PrinterShareName),'') PrinterShareName, 
				isnull(trim(PrinterDriverVersion),'') PrinterDriverVersion, 
				isnull(trim(PrinterDriverName),'') PrinterDriverName, 
				isnull(trim(PrinterIP),'') PrinterIP, 
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(PrinterName,''))) ,
								case when convert(bit,PrinterShared) = 1 then '1' else '0' end, 
								lower(convert(varchar,isnull(PrinterShareName,''))), 
								lower(convert(varchar,isnull(PrinterDriverName,''))),
								lower(convert(varchar,isnull(PrinterDriverVersion,''))),
								lower(convert(varchar,isnull(PrinterIP,'')))
							)
						)
			into #sourceHashedParameter
			from @printers;





			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, printer) tuple is current
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
										lower(convert(varchar,isnull(PrinterName,''))),
										case when PrinterShared = 1 then '1' else '0' end, 
										lower(convert(varchar,isnull(PrinterShareName,''))), 
										lower(convert(varchar,isnull(PrinterDriverName,''))),
										lower(convert(varchar,isnull(PrinterDriverVersion,''))),
										lower(convert(varchar,isnull(PrinterIP,'')))
									)
								)
					from dbo.WorkstationPrinters wp;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & printer name tuple
				begin try
					begin transaction;

					;with cte as (
						select wp.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, PrinterName order by PrinterScanSuccessDate desc) 
						from dbo.WorkstationPrinters wp
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & printer name tuple 
				begin try
					begin transaction;
						;with cte as (
							select wp.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, PrinterName order by PrinterScanSuccessDate desc) 
							from dbo.WorkstationPrinters wp
				
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
				from dbo.WorkstationPrinters
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->printer-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-printer-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> printer status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->printer-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->printer-removed->set-IsCurrent=0'
				from dbo.WorkstationPrinters dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.PrinterName = dst.PrinterName
						)
				;

				-- scenario-2:destination-is-null->new-printer-found->insert
				insert into dbo.WorkstationPrinters(
						ComputerName, PrinterName,PrinterShared, PrinterShareName, 
						PrinterDriverName, PrinterDriverVersion, PrinterIP,
						PrinterScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, PrinterName,PrinterShared, PrinterShareName, 
					PrinterDriverName, PrinterDriverVersion, PrinterIP,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-printer-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationPrinters dst
							where dst.ComputerName = src.ComputerName
								and dst.PrinterName = src.PrinterName
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set PrinterScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationPrinters dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.PrinterName = dst.PrinterName and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> printer status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> printer drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationPrinters dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.PrinterName = dst.PrinterName 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationPrinters(
						ComputerName, PrinterName,PrinterShared, PrinterShareName, 
						PrinterDriverName, PrinterDriverVersion, PrinterIP,
						PrinterScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, PrinterName,PrinterShared, PrinterShareName, 
					PrinterDriverName, PrinterDriverVersion, PrinterIP,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationPrinters dst
							where dst.ComputerName = src.ComputerName
								and dst.PrinterName = src.PrinterName
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
