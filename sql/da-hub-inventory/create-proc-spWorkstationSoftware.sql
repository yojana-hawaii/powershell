use DaHubInventory
go
drop proc if exists spWorkstationSoftware
go
create proc spWorkstationSoftware
(
	@ComputerName varchar(50) ,
	@SoftwareName varchar(100) ,
	@SoftwareVendor  varchar(100) = null ,
	@SoftwareVersion  varchar(100) = null,
	@SoftwareInstallDate  varchar(100) = null,
	@SoftwareInstallLocation varchar(100) = null,
	@SoftwareInstallSource varchar(100) = null
)
as
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSoftware
	set
		SoftwareVendor = @SoftwareVendor,
		SoftwareVersion = @SoftwareVersion,
		SoftwareInstallDate = Convert(date, @SoftwareInstallDate),
		SoftwareInstallLocation = case when @SoftwareInstallLocation = '' then null else @SoftwareInstallLocation end,
		SoftwareInstallSource = case when @SoftwareInstallSource = '' then null else @SoftwareInstallSource end,
		SoftwareScanSuccessDate = @now
	where ComputerName = @ComputerName
		and SoftwareName = @SoftwareName;
	 
	 if @@ROWCOUNT = 0
	 begin
		insert into dbo.WorkstationSoftware(
			ComputerName, 
			SoftwareName, SoftwareVendor, SoftwareVersion,SoftwareInstallDate,
			SoftwareInstallLocation,
			SoftwareInstallSource,
			SoftwareScanSuccessDate
			)
		select 
			@ComputerName, 
			@SoftwareName, @SoftwareVendor, @SoftwareVersion,convert(date,@SoftwareInstallDate),
			case when @SoftwareInstallLocation = '' then null else @SoftwareInstallLocation end, 
			case when @SoftwareInstallSource = '' then null else @SoftwareInstallSource end, 
			@now
	 end

end

go

select * from dbo.WorkstationSoftware
go