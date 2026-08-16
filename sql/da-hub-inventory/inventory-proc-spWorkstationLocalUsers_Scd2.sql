use DaHubInventory
go


drop proc if exists dbo.spWorkstationLocalUsers_Scd2
go
create proc dbo.spWorkstationLocalUsers_Scd2
	@localusers dbo.tvpWorkstationLocalUsers readonly
as 
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

			-- Guard: reject duplicate
			if exists (
				select ComputerName, LocalUserName
				from @localusers
				where ComputerName is not null and LocalUserName is not null
				group by ComputerName, LocalUserName
				having count(*) > 1
			)
			begin;
				throw 51001, 'Custom exception: duplicate computername, LocalUserName found in source', 1;
			end
			;

			-- Guard: reject null
			if exists (select 1 from @localusers where ComputerName is null or LocalUserName is null)
			begin;
				throw 51001, 'Custom exception: ComputerName and ServicName canot be NULL',1;
			end;


			-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
			drop table if exists #sourceHashedParameter;
			select 
				ComputerName, 
				LocalUserName, 
				isnull(trim(LocalUserStatus),'') LocalUserStatus, 

				convert(bit,LocalUserLocalAccount) LocalUserLocalAccount, 
				convert(bit,LocalUserPasswordExpires) LocalUserPasswordExpires, 
				convert(bit,LocalUserDisabled) LocalUserDisabled, 
				convert(bit,LocalUserLockout) LocalUserLockout, 
				convert(bit,LocalUserPasswordChangeable) LocalUserPasswordChangeable, 
				convert(bit,LocalUserPasswordRequired) LocalUserPasswordRequired, 

				isnull(trim(LocalUserDescription),'') LocalUserDescription, 
				isnull(trim(LocalUserFullName),'') LocalUserFullName, 
				isnull(trim(LocalUserAccountType),'') LocalUserAccountType, 
				convert(date, LocalUserInstallDate) LocalUserInstallDate, 
				RowHash = hashbytes(
							'sha2_256', 
							concat(
								lower(convert(varchar,isnull(ComputerName,''))), 
								lower(convert(varchar,isnull(LocalUserName,''))),
								lower(convert(varchar,isnull(LocalUserStatus,''))), 
								case when LocalUserLocalAccount = 1 then '1' else '0' end, 
								case when LocalUserPasswordExpires = 1 then '1' else '0' end, 
								case when LocalUserDisabled = 1 then '1' else '0' end, 
								case when LocalUserLockout = 1 then '1' else '0' end, 
								case when LocalUserPasswordChangeable = 1 then '1' else '0' end, 
								case when LocalUserPasswordRequired = 1 then '1' else '0' end, 
								lower(convert(varchar,isnull(LocalUserDescription,''))),
								lower(convert(varchar,isnull(LocalUserFullName,''))),
								lower(convert(varchar,isnull(LocalUserAccountType,''))),
								lower(convert(varchar,isnull(LocalUserInstallDate,'')))
							)
						)
			into #sourceHashedParameter
			from @localusers;


			/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
			1. update rowhash
			2. expireDate = null
			3. last row for (computer, local-user) tuple is current
			*/
			declare @reset int = 0;
			if @reset = 1
			begin
				-- Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
				begin try
					begin transaction;

					update wl
					set wl.IsCurrent = 0,
						wl.ExpiryDate = null,
						wl.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
						RowHash = hashbytes(
									'sha2_256', 
									concat(
										lower(convert(varchar,isnull(ComputerName,''))), 
										lower(convert(varchar,isnull(LocalUserName,''))),
										lower(convert(varchar,isnull(LocalUserStatus,''))), 
										case when LocalUserLocalAccount = 1 then '1' else '0' end, 
										case when LocalUserPasswordExpires = 1 then '1' else '0' end, 
										case when LocalUserDisabled = 1 then '1' else '0' end, 
										case when LocalUserLockout = 1 then '1' else '0' end, 
										case when LocalUserPasswordChangeable = 1 then '1' else '0' end, 
										case when LocalUserPasswordRequired = 1 then '1' else '0' end, 
										lower(convert(varchar,isnull(LocalUserDescription,''))),
										lower(convert(varchar,isnull(LocalUserFullName,''))),
										lower(convert(varchar,isnull(LocalUserAccountType,''))),
										lower(convert(varchar,isnull(LocalUserInstallDate,'')))
									)
								)
					from dbo.WorkstationLocalUsers wl;

					commit transaction;
				end try
				begin catch
					if @@trancount > 0 rollback transaction;
					throw;
				end catch;

	
				-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & local-user name tuple
				begin try
					begin transaction;

					;with cte as (
						select wl.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, LocalUserName order by LocalUserScanSuccessDate desc) 
						from dbo.WorkstationLocalUsers wl
				
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

				-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & local-user name tuple 
				begin try
					begin transaction;
						;with cte as (
							select wl.*, 
								RowNum = ROW_NUMBER() over(partition by ComputerName, LocalUserName order by LocalUserScanSuccessDate desc) 
							from dbo.WorkstationLocalUsers wl
				
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
				from dbo.WorkstationLocalUsers
				group by SlowlyChangingDimensionReason;


			end
			;


		
			/* 6 possibility
				-- scenario-1:source-is-null->local-user-removed->set-IsCurrent=0
				-- scenario-2:destination-is-null->new-local-user-found->insert
				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				-- scenario 5: hash no match && IsCurrent=1 -> local-user status changed
				-- step 5.1: change those to not current
				-- step 5.2: insert new
				-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			*/
			;

			begin try 
				begin transaction;

				-- scenario-1:source-is-null->local-user-removed->set-IsCurrent=0
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'scenario-1:source-is-null->local-user-removed->set-IsCurrent=0'
				from dbo.WorkstationLocalUsers dst
				where dst.IsCurrent = 1
					and dst.ComputerName = (select distinct computername from #sourceHashedParameter)
					and not exists (
							select 1 
							from #sourceHashedParameter src
							where src.ComputerName = dst.ComputerName
								and src.LocalUserName = dst.LocalUserName
						)
				;

				-- scenario-2:destination-is-null->new-local-user-found->insert
				insert into dbo.WorkstationLocalUsers(
					ComputerName, LocalUserName, LocalUserStatus, LocalUserLocalAccount, LocalUserPasswordExpires, LocalUserDisabled, LocalUserLockout, 
					LocalUserPasswordChangeable, LocalUserPasswordRequired, LocalUserDescription, LocalUserFullName, LocalUserAccountType,LocalUserInstallDate,
					LocalUserScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, LocalUserName, LocalUserStatus, LocalUserLocalAccount, LocalUserPasswordExpires, LocalUserDisabled, LocalUserLockout, 
					LocalUserPasswordChangeable, LocalUserPasswordRequired, LocalUserDescription, LocalUserFullName, LocalUserAccountType,LocalUserInstallDate,
					@now,
					@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-local-user-found->insert'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationLocalUsers dst
							where dst.ComputerName = src.ComputerName
								and dst.LocalUserName = src.LocalUserName
								and dst.IsCurrent = 1
						)
				;

				-- scenario-3:hash-match-&&-IsCurrent=1->no-change
				update dst	
					set LocalUserScanSuccessDate = @now,
						SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
				from dbo.WorkstationLocalUsers dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.LocalUserName = dst.LocalUserName and src.rowhash = dst.RowHash
				where dst.IsCurrent = 1
				;

				-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
				;


				-- scenario 5: hash no match && IsCurrent=1 -> local-user status changed
				-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
				update dst 
					set IsCurrent = 0,
						ExpiryDate = @now,
						SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> local-user drive or IP changed -> set-IsCurrent=0 && add expiration date'
				from dbo.WorkstationLocalUsers dst
					inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.LocalUserName = dst.LocalUserName 
				where dst.IsCurrent = 1
					and src.rowhash <> dst.RowHash
				;

				-- step 5.2: hash no-match -> removed old row -> now insert new
				insert into dbo.WorkstationLocalUsers(
						ComputerName, LocalUserName, LocalUserStatus, LocalUserLocalAccount, LocalUserPasswordExpires, LocalUserDisabled, LocalUserLockout, 
						LocalUserPasswordChangeable, LocalUserPasswordRequired, LocalUserDescription, LocalUserFullName, LocalUserAccountType,LocalUserInstallDate,
						LocalUserScanSuccessDate,
						EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
					)
				select
					ComputerName, LocalUserName, LocalUserStatus, LocalUserLocalAccount, LocalUserPasswordExpires, LocalUserDisabled, LocalUserLockout, 
					LocalUserPasswordChangeable, LocalUserPasswordRequired, LocalUserDescription, LocalUserFullName, LocalUserAccountType,LocalUserInstallDate,
					@now,
					@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
				from #sourceHashedParameter src
				where  not exists (
							select 1 
							from dbo.WorkstationLocalUsers dst
							where dst.ComputerName = src.ComputerName
								and dst.LocalUserName = src.LocalUserName
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
