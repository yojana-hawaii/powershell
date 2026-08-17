use DaHubInventory
go


drop proc if exists dbo.spWorkstationUserLoggedIn_Scd2
go
create proc dbo.spWorkstationUserLoggedIn_Scd2
	@userloggedin dbo.tvpWorkstationUserLoggedIn readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate
			if exists (
				select ComputerName, UserLoggedIn
				from @userloggedin
				where ComputerName is not null and UserLoggedIn is not null
				group by ComputerName, UserLoggedIn
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, UserLoggedIn found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @userloggedin where ComputerName is null or UserLoggedIn is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and Userlogged In canot be NULL',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				UserLoggedIn, 
				isnull(trim(UserLastLoggedInDate),'') UserLastLoggedInDate, 
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(UserLoggedIn,''))) ,
								lower(convert(varchar,isnull(UserLastLoggedInDate,'')))
							)
						)
			into #sourceHashedParameter
			from @userloggedin;





			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, user-logged-in) tuple is current
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
										lower(convert(varchar,isnull(UserLoggedIn,''))) ,
										lower(convert(varchar,isnull(UserLastLoggedInDate,'')))
									)
								)
					from dbo.WorkstationUserLoggedIn wp;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & user-logged-in name tuple
				begin try
					begin transaction;

					;with cte as (
						select wp.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, UserLoggedIn order by UserLoggedInScanSuccessDate desc) 
						from dbo.WorkstationUserLoggedIn wp
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & user-logged-in name tuple 
				begin try
					begin transaction;
						;with cte as (
							select wp.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, UserLoggedIn order by UserLoggedInScanSuccessDate desc) 
							from dbo.WorkstationUserLoggedIn wp
				
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
				from dbo.WorkstationUserLoggedIn
				group by SlowlyChangingDimensionReason;


			end
			;
			

		
			/* 6 possibility
				-- scenario-1:source-is-null->user-logged-in-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-user-logged-in-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> user-logged-in status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->user-logged-in-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->user-logged-in-removed->set-IsCurrent=0'
				from dbo.WorkstationUserLoggedIn dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.UserLoggedIn = dst.UserLoggedIn
						)
				;

				-- scenario-2:destination-is-null->new-user-logged-in-found->insert
				insert into dbo.WorkstationUserLoggedIn(
						ComputerName, UserLoggedIn,UserLastLoggedInDate,
						UserLoggedInScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, UserLoggedIn,UserLastLoggedInDate,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-user-logged-in-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationUserLoggedIn dst
							where dst.ComputerName = src.ComputerName
								and dst.UserLoggedIn = src.UserLoggedIn
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set UserLoggedInScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationUserLoggedIn dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.UserLoggedIn = dst.UserLoggedIn and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> user-logged-in status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> user-logged-in drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationUserLoggedIn dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.UserLoggedIn = dst.UserLoggedIn 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationUserLoggedIn(
						ComputerName, UserLoggedIn,UserLastLoggedInDate,
						UserLoggedInScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, UserLoggedIn,UserLastLoggedInDate,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationUserLoggedIn dst
							where dst.ComputerName = src.ComputerName
								and dst.UserLoggedIn = src.UserLoggedIn
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
