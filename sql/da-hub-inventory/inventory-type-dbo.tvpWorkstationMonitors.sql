
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationMonitors;
go
create type dbo.tvpWorkstationMonitors as table (
	ComputerName varchar(50),
    MonitorManufacturer varchar(50),
    MonitorName varchar(50),
    MonitorSerial varchar(50),
    MonitorYear varchar(50),
    MonitorCaption varchar(50),
    MonitorResolution varchar(50)
);

go

