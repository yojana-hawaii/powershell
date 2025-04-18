use DaHubInventory
go

drop proc if exists dbo.spWorkstationMonitors
go
create proc dbo.spWorkstationMonitors
(
	@ComputerName varchar(50),
    @MonitorManufacturer varchar(50) = null,
    @MonitorName varchar(50) = null,
    @MonitorSerial varchar(50) = null,
    @MonitorYear varchar(50) = null,
    @MonitorCaption varchar(50) = null,
    @MonitorResolution varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationMonitors
	set MonitorName = @MonitorName,
		MonitorManufacturer = @MonitorManufacturer,
		MonitorYear = @MonitorYear,
		MonitorCaption = @MonitorCaption,
		MonitorResolution = @MonitorResolution,
		MonitorScanSuccessDate = @now
	where ComputerName = @ComputerName
		and MonitorSerial = @MonitorSerial

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationMonitors(ComputerName, 
				MonitorName, MonitorManufacturer,MonitorYear,MonitorCaption, MonitorResolution,MonitorSerial,
				MonitorScanSuccessDate)
		select @ComputerName,
				@MonitorName, @MonitorManufacturer,@MonitorYear,@MonitorCaption, @MonitorResolution,@MonitorSerial,
				@now
	end

end

go
select * from dbo.WorkstationMonitors
go