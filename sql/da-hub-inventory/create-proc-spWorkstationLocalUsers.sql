use DaHubInventory
go

drop proc if exists dbo.spWorkstationLocalUsers
go
create proc dbo.spWorkstationLocalUsers
(
	@ComputerName varchar(50),
	@Name varchar(100) = null,
	@LocalAccount varchar(100) = null,

	@PasswordExpires varchar(100) = null,
	@Disabled varchar(100) = null,
	@Lockout varchar(100) = null,
	@PasswordChangeable varchar(100) = null,
	@PasswordRequired varchar(100) = null,

	@Description varchar(500) = null,
	@Status varchar(50) = null,
	@FullName varchar(100) = null,
	@AccountType varchar(50) = null,

	@InstallDate varchar(100) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationLocalUsers
	set
		LocalUserLocalAccount = convert(bit, @LocalAccount),
		LocalUserPasswordExpires = convert(bit, @PasswordExpires),
		LocalUserDisabled = convert(bit, @Disabled),
		LocalUserLockout = convert(bit,@Lockout),
		LocalUserPasswordChangeable = convert(bit,@PasswordChangeable),
		LocalUserPasswordRequired = convert(bit,@PasswordRequired),

		LocalUserStatus = @Status,
		LocalUserFullName = @Status,
		LocalUserDescription = @Status,
		LocalUserAccountType = @Status,

		LocalUserInstallDate = convert(date,@InstallDate),

		LocalUserScanSuccessDate	= @now
	where ComputerName = @ComputerName and LocalUserName = @Name;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationLocalUsers(ComputerName, 
			LocalUserPasswordExpires,LocalUserDisabled,LocalUserLocalAccount, LocalUserLockout,LocalUserPasswordChangeable, LocalUserPasswordRequired,
			LocalUserName, LocalUserStatus, LocalUserFullName, LocalUserAccountType, LocalUserDescription,
			LocalUserInstallDate,
			LocalUserScanSuccessDate)
		select @ComputerName,
			@PasswordExpires, @Disabled, @LocalAccount, @Lockout, @PasswordChangeable, @PasswordRequired, 
			@Name, @Status, @FullName, @AccountType, @Description,
			@InstallDate,
		 	@now
	end

end

go
select * from dbo.WorkstationLocalUsers
go