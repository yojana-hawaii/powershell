
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationPrinters;
go
create type dbo.tvpWorkstationPrinters as table (
	ComputerName varchar(50),
	PrinterName varchar(100),
	PrinterShared  varchar(100) ,
	PrinterShareName varchar(100),
	PrinterDriverName  varchar(100),
	PrinterDriverVersion varchar(100),
	PrinterIP varchar(100)
);

go

