use DaHubInventory
go

--drop table if exists dbo.WorkstationMonitors;
go 

create table dbo.WorkstationMonitors
(
	ComputerName varchar(50),
    MonitorManufacturer varchar(50),
    MonitorName varchar(50),
    MonitorSerial varchar(50),
    MonitorYear varchar(50),
    MonitorCaption varchar(50),
    MonitorResolution varchar(50),
	MonitorScanSuccessDate datetime,

	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
);

go
select top 10 * from DaHubInventory.dbo.WorkstationMonitors
go