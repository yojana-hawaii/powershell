use DaHubInventory
go
--drop table if exists dbo.WorkstationPrinters
go
create table dbo.WorkstationPrinters
(
	ComputerName varchar(50),
	PrinterName varchar(100),
	PrinterShared  bit ,
	PrinterShareName varchar(100),
	PrinterDriverName  varchar(50) null,
	PrinterDriverVersion varchar(50) null,
	PrinterIP varchar(50) null,
	PrinterScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
)
go 
select * from dbo.WorkstationPrinters
go
