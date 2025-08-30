

use DaHubInventory
go

drop proc if exists dbo.spAdComputers
go
create proc dbo.spAdComputers
(
	@ComputerName varchar(50) ,

	@Enabled varchar(50) = null,
    @HasBitlocker varchar(50) = null,
    @Haslaps varchar(50) = null,

	@DistinguishedName varchar(100) = null,
    @OU varchar(100) = null,
    @sAMAccountName varchar(50) = null,
    @IPV4Address varchar(20) = null,
	@OperatingSystem varchar(50) = null,
    @OperatingSystemVersion varchar(50) = null,
    @Description varchar(500) = null,
	@UserAccountControl varchar(100) = null,

    @CreatedDate varchar(50) = null,
	@ModifiedDate varchar(50) = null,
    @BitLockerPasswordDate varchar(50) = null,
    @LapsExpirationDate varchar(50) = null,
    @LastLogonDate varchar(50) = null,

    @LogonCount varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();



	--update existing Computers
	update dbo.AdComputers
	set
		Enabled = convert(bit, @Enabled),
		HasBitlocker = convert(bit, @HasBitlocker),
		Haslaps = convert(bit, @Haslaps),

		DistinguishedName = @DistinguishedName,
		OU = @OU,
		sAMAccountName = @sAMAccountName,
		IPV4Address = @IPV4Address,
		OperatingSystem = @OperatingSystem,
		OperatingSystemVersion = @OperatingSystemVersion,
		Description = @Description,
		UserAccountControl = @UserAccountControl,

		CreatedDate = convert(datetime, @CreatedDate),
		ModifiedDate = convert(datetime, @ModifiedDate),
		BitLockerPasswordDate = convert(datetime, @BitLockerPasswordDate),
		LapsExpirationDate = convert(datetime, @LapsExpirationDate),
		LastLogonDate = convert(datetime, @LastLogonDate),

		LogonCount = convert(int,@LogonCount),
		[Location] = case when @location is null then [Location] else @location end, 
		AdComputerScanSuccessDate	= @now
	where ComputerName = @ComputerName;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.AdComputers(ComputerName, 
				Enabled, HasBitlocker, Haslaps,
				DistinguishedName, OU,sAMAccountName,IPV4Address,OperatingSystem, OperatingSystemVersion, Description,UserAccountControl,
				CreatedDate, ModifiedDate, BitLockerPasswordDate, LapsExpirationDate, LastLogonDate,
				LogonCount,
				AdComputerScanSuccessDate)
		select @ComputerName,
				@Enabled, @HasBitlocker, @Haslaps,
				@DistinguishedName, @OU, @sAMAccountName, @IPV4Address, @OperatingSystem, @OperatingSystemVersion, @Description,@UserAccountControl,
				@CreatedDate, @ModifiedDate, @BitLockerPasswordDate, @LapsExpirationDate, @LastLogonDate,
				@LogonCount,
				@now
	end

end

go
select * from dbo.AdComputers
go