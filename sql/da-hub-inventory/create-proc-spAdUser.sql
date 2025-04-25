
use DaHubInventory
go
drop proc if exists dbo.spAdUser;
go
create proc dbo.spAdUser
(
	@CanonicalName varchar(100) , 
	@sAMAccountName varchar(50) ,
	@userPrincipalName varchar(50) = null,
	@FirstName varchar(50) = null,
	@LastName varchar(50) = null,
	@DisplayName varchar(50) = null,
	@emailAddress varchar(50) = null,
	@DistinguishedName varchar(100) = null,
	@StreetAddress varchar(50) = null,
	@HomePhone varchar(50) = null,
	@MobilePhone varchar(50) = null,
	@OfficePhone varchar(50) = null,
	@Fax varchar(50) = null,
	@Company varchar(50) = null,
	@Department varchar(50) = null,
	@Title varchar(50) = null,
	@Description varchar(500) = null,
	@AccountExpirationDate  varchar(50) = null,
	@Enabled  varchar(50) = null,
	@LastLogonDate  varchar(50) = null,
	@CreatedDate  varchar(50) = null,
	@ModifiedDate  varchar(50) = null,
	@PasswordNeverExpires  varchar(50) = null,
	@PasswordExpired  varchar(50) = null,
	@PasswordLastSetDate  varchar(50) = null,
	@ScriptPath varchar(50) = null,
	@LogonCount varchar(50) = null,
	@EmployeeId varchar(50) = null,
	@Manager varchar(50) = null
)
as 
	begin
		declare @now datetime2 = getdate();

		set @PasswordLastSetDate = case when @PasswordLastSetDate is null or trim(@PasswordLastSetDate) = '' then null else @PasswordLastSetDate end
		set @AccountExpirationDate = case when @AccountExpirationDate is null or trim(@AccountExpirationDate) = '' then null else @AccountExpirationDate end
		set @LastLogonDate = case when @LastLogonDate is null or trim(@LastLogonDate) = '' then null else @LastLogonDate end
		set @CreatedDate = case when @CreatedDate is null or trim(@CreatedDate) = '' then null else @CreatedDate end
		set @ModifiedDate = case when @ModifiedDate is null or trim(@ModifiedDate) = '' then null else @ModifiedDate end

		set @PasswordNeverExpires = case when @PasswordNeverExpires is null or trim(@PasswordNeverExpires) = '' then null else @PasswordNeverExpires end

		update dbo.AdUsers
		set
			CanonicalName = @CanonicalName, 
			userPrincipalName = @userPrincipalName, 
			FirstName = @FirstName,
			LastName = @LastName,
			DisplayName = @DisplayName, 
			emailAddress = @emailAddress, 
			DistinguishedName = @DistinguishedName, 
			StreetAddress = @StreetAddress,
			HomePhone = @HomePhone, 
			MobilePhone = @MobilePhone, 
			OfficePhone= @OfficePhone, 
			Fax = @Fax,
			Company = @Company,
			Department = @department,
			Title = @title,
			Description = @Description,
			AccountExpirationDate = @AccountExpirationDate,
			Enabled = convert(bit,@Enabled),
			LastLogonDate = @LastLogonDate,
			CreatedDate = @CreatedDate,
			ModifiedDate = @ModifiedDate,
			PasswordNeverExpires = @PasswordNeverExpires,
			PasswordExpired = convert(bit, @PasswordExpired),
			PasswordLastSetDate = @PasswordLastSetDate,
			ScriptPath = @ScriptPath,
			LogonCount = convert(int, @LogonCount),
			EmployeeId = @EmployeeId,
			Manager = @Manager,
    
			AdUserScanSuccessDate = @now
		where sAMAccountName = @sAMAccountName;

		if @@ROWCOUNT = 0
		begin
			insert into dbo.AdUsers (CanonicalName, userPrincipalName, sAMAccountName, FirstName, LastName, 
						DisplayName, emailAddress, DistinguishedName, StreetAddress,HomePhone, 
						MobilePhone, OfficePhone, fax, Company, Department, 
						Title, Description,AccountExpirationDate, Enabled, LastLogonDate,
						CreatedDate, ModifiedDate, PasswordNeverExpires, PasswordExpired, PasswordLastSetDate, 
						ScriptPath, LogonCount, EmployeeId, Manager,
						AdUserScanSuccessDate)
			select @CanonicalName, @userPrincipalName, @sAMAccountName, @FirstName, @LastName, 
						@DisplayName, @emailAddress, @DistinguishedName, @StreetAddress,@HomePhone, 
						@MobilePhone, @OfficePhone, @fax, @Company, @Department, 
						@Title, @Description, @AccountExpirationDate, convert(bit, @Enabled), @LastLogonDate,
						@CreatedDate,  @ModifiedDate, @PasswordNeverExpires, convert(bit,@PasswordExpired), @PasswordLastSetDate, 
						@ScriptPath, convert(int,@LogonCount), @EmployeeId,@Manager,
						@now
		end

end
go

select * from DaHubInventory.dbo.AdUsers

go