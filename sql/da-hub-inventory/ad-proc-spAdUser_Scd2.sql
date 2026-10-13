
use DaHubInventory
go
drop proc if exists dbo.spAdUsers_Scd2;
go
create proc dbo.spAdUsers_Scd2
	@users dbo.tvpAdUsers readonly
as
	begin
		set nocount on;
	declare @now datetime2 = getdate();

	
	begin try 
		-- Guard: reject duplicate
		if exists (
			select SamAccountName
			from @users
			where SamAccountName is not null
			group by SamAccountName
			having count(*) > 1
		)
		begin;
			throw 51001, 'Custom exception: duplicate SamAccountName found in source', 1;
		end
		;

		-- Guard: reject null
		if exists (select 1 from @users where SamAccountName is null)
		begin;
			throw 51001, 'Custom exception: SamAccountName canot be NULL',1;
		end;


		-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
		drop table if exists #sourceHashedParameter;
		select  
			convert(varchar(max),CanonicalName) CanonicalName,
			convert(varchar(50),SamAccountName) SamAccountName,
			convert(varchar(50),userPrincipalName) userPrincipalName,
			convert(varchar(50),FirstName) FirstName,
			convert(varchar(50),LastName) LastName,
			convert(varchar(100),DisplayName) DisplayName,
			convert(varchar(100),emailAddress) emailAddress,
			convert(varchar(max),DistinguishedName) DistinguishedName,
			convert(varchar(max),StreetAddress) StreetAddress,
			convert(varchar(50),HomePhone) HomePhone,
			convert(varchar(50),MobilePhone) MobilePhone,
			convert(varchar(50),OfficePhone) OfficePhone,
			convert(varchar(50),Fax) Fax,
			convert(varchar(50),Company) Company,
			convert(varchar(50),Department) Department,
			convert(varchar(100),Title) Title,
			convert(varchar(max),Description) Description,
			convert(datetime2,AccountExpirationDate) AccountExpirationDate,
			convert(bit,Enabled) Enabled,
			convert(datetime2,LastLogonDate) LastLogonDate,
			convert(datetime2,CreatedDate) CreatedDate,
			convert(datetime2,ModifiedDate) ModifiedDate,
			convert(bit,PasswordNeverExpires) PasswordNeverExpires,
			convert(bit,PasswordExpired) PasswordExpired,
			convert(datetime2,PasswordLastSetDate) PasswordLastSetDate,
			convert(varchar(50),ScriptPath) ScriptPath,
			convert(int,LogonCount) LogonCount,
			convert(varchar(50),EmployeeId) EmployeeId,
			convert(varchar(50),Manager) Manager,

			RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(SamAccountName,''))), 
							lower(convert(varchar,isnull(CanonicalName,''))),
							lower(convert(varchar,isnull(userPrincipalName,''))),
							lower(convert(varchar,isnull(FirstName,''))),
							lower(convert(varchar,isnull(LastName,''))),

							lower(convert(varchar,isnull(DisplayName,''))),
							lower(convert(varchar,isnull(emailAddress,''))),
							lower(convert(varchar,isnull(DistinguishedName,''))),
							lower(convert(varchar,isnull(StreetAddress,''))),

							lower(convert(varchar,isnull(HomePhone,''))),
							lower(convert(varchar,isnull(MobilePhone,''))),
							lower(convert(varchar,isnull(OfficePhone,''))),
							lower(convert(varchar,isnull(Fax,''))),

							lower(convert(varchar,isnull(Company,''))),
							lower(convert(varchar,isnull(Department,''))),
							lower(convert(varchar,isnull(Title,''))),
							lower(convert(varchar,isnull(Department,''))),

							isnull(AccountExpirationDate,''),
							lower(convert(varchar,isnull(Enabled,''))),
							isnull(LastLogonDate,''),
							isnull(CreatedDate,''),
							isnull(ModifiedDate,''),

							lower(convert(varchar,isnull(PasswordNeverExpires,''))),
							lower(convert(varchar,isnull(PasswordExpired,''))),
							isnull(PasswordLastSetDate,''),

							lower(convert(varchar,isnull(ScriptPath,''))),
							lower(convert(varchar,isnull(LogonCount,''))),
							lower(convert(varchar,isnull(EmployeeId,''))),

							lower(convert(varchar,isnull(Manager,'')))

						)
					)
		into #sourceHashedParameter
		from @users;

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

				update au
				set au.IsCurrent = 0,
					au.ExpiryDate = null,
					au.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
					RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(SamAccountName,''))), 
							lower(convert(varchar,isnull(CanonicalName,''))),
							lower(convert(varchar,isnull(userPrincipalName,''))),
							lower(convert(varchar,isnull(FirstName,''))),
							lower(convert(varchar,isnull(LastName,''))),

							lower(convert(varchar,isnull(DisplayName,''))),
							lower(convert(varchar,isnull(emailAddress,''))),
							lower(convert(varchar,isnull(DistinguishedName,''))),
							lower(convert(varchar,isnull(StreetAddress,''))),

							lower(convert(varchar,isnull(HomePhone,''))),
							lower(convert(varchar,isnull(MobilePhone,''))),
							lower(convert(varchar,isnull(OfficePhone,''))),
							lower(convert(varchar,isnull(Fax,''))),

							lower(convert(varchar,isnull(Company,''))),
							lower(convert(varchar,isnull(Department,''))),
							lower(convert(varchar,isnull(Title,''))),
							lower(convert(varchar,isnull(Department,''))),

							isnull(AccountExpirationDate,''),
							lower(convert(varchar,isnull(Enabled,''))),
							isnull(LastLogonDate,''),
							isnull(CreatedDate,''),
							isnull(ModifiedDate,''),

							lower(convert(varchar,isnull(PasswordNeverExpires,''))),
							lower(convert(varchar,isnull(PasswordExpired,''))),
							isnull(PasswordLastSetDate,''),

							lower(convert(varchar,isnull(ScriptPath,''))),
							lower(convert(varchar,isnull(LogonCount,''))),
							lower(convert(varchar,isnull(EmployeeId,''))),

							lower(convert(varchar,isnull(Manager,'')))

						)
					)
				from dbo.AdUsers au

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
					select au.*, 
						RowNum = ROW_NUMBER() over(partition by SamAccountName order by AdUserScanSuccessDate desc) 
					from dbo.AdUsers au
				
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
						select au.*, 
							RowNum = ROW_NUMBER() over(partition by SamAccountName order by AdUserScanSuccessDate desc) 
						from dbo.AdUsers au
				
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
			from dbo.AdUsers
			group by SlowlyChangingDimensionReason;


		end
		
		/* 6 possibility
			 scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			 scenario-2:destination-is-null->new-partition-number-found->insert
			 scenario-3:hash-match-&&-IsCurrent=1->no-change
			 scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			 scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
			 step 5.1: change those to not current
			 step 5.2: insert new
			 scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
		*/
		;

		begin try 
			begin transaction;

			-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0'
			from dbo.AdUsers dst
			where dst.IsCurrent = 1
				and dst.SamAccountName in (select distinct SamAccountName from #sourceHashedParameter)
				and not exists (
						select 1 
						from #sourceHashedParameter src
						where src.SamAccountName = dst.SamAccountName
					)
			;
			
				
			-- scenario-2:destination-is-null->new-user-found->insert
			insert into dbo.AdUsers(
					CanonicalName,sAMAccountName,userPrincipalName,FirstName,LastName,
					DisplayName,emailAddress,DistinguishedName,StreetAddress,
					HomePhone,MobilePhone,OfficePhone,Fax,
					Company,Department,Title,Description,
					AccountExpirationDate,Enabled,LastLogonDate,CreatedDate,ModifiedDate,
					PasswordNeverExpires,PasswordExpired,PasswordLastSetDate,
					ScriptPath,LogonCount,EmployeeId,
					Manager,
					AdUserScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				CanonicalName,sAMAccountName,userPrincipalName,FirstName,LastName,
				DisplayName,emailAddress,DistinguishedName,StreetAddress,
				HomePhone,MobilePhone,OfficePhone,Fax,
				Company,Department,Title,Description,
				AccountExpirationDate,Enabled,LastLogonDate,CreatedDate,ModifiedDate,
				PasswordNeverExpires,PasswordExpired,PasswordLastSetDate,
				ScriptPath,LogonCount,EmployeeId,
				Manager,
				@now,
				@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-user-found->insert'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdUsers dst
						where dst.SamAccountName = src.SamAccountName
							and dst.IsCurrent = 1
					)
			;

			-- scenario-3:hash-match-&&-IsCurrent=1->no-change
			update dst	
				set AdUserScanSuccessDate = @now,
					SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
			from dbo.AdUsers dst
				inner join #sourceHashedParameter src on src.SamAccountName = dst.SamAccountName and src.rowhash = dst.RowHash
			where dst.IsCurrent = 1
			;

			-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			;


			-- scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
			-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> user details changed -> set-IsCurrent=0 && add expiration date'
			from dbo.AdUsers dst
				inner join #sourceHashedParameter src on src.SamAccountName = dst.SamAccountName
			where dst.IsCurrent = 1
				and src.rowhash <> dst.RowHash
			;

			-- step 5.2: hash no-match -> removed old row -> now insert new
			insert into dbo.AdUsers(
					CanonicalName,sAMAccountName,userPrincipalName,FirstName,LastName,
					DisplayName,emailAddress,DistinguishedName,StreetAddress,
					HomePhone,MobilePhone,OfficePhone,Fax,
					Company,Department,Title,Description,
					AccountExpirationDate,Enabled,LastLogonDate,CreatedDate,ModifiedDate,
					PasswordNeverExpires,PasswordExpired,PasswordLastSetDate,
					ScriptPath,LogonCount,EmployeeId,
					Manager,
					AdUserScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				CanonicalName,sAMAccountName,userPrincipalName,FirstName,LastName,
				DisplayName,emailAddress,DistinguishedName,StreetAddress,
				HomePhone,MobilePhone,OfficePhone,Fax,
				Company,Department,Title,Description,
				AccountExpirationDate,Enabled,LastLogonDate,CreatedDate,ModifiedDate,
				PasswordNeverExpires,PasswordExpired,PasswordLastSetDate,
				ScriptPath,LogonCount,EmployeeId,
				Manager,
				@now,
				@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-user-found->insert'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdUsers dst
						where dst.SamAccountName = src.SamAccountName
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

select AdUserScanSuccessDate scaned, * from DaHubInventory.dbo.AdUsers where IsCurrent = 1 order by AdUserScanSuccessDate desc

go