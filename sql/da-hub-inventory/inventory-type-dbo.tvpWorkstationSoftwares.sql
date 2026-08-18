
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationSoftwares;
go
create type dbo.tvpWorkstationSoftwares as table (
	ComputerName varchar(50),
	SoftwareName varchar(100),
	SoftwareVendor  varchar(100) ,
	SoftwareVersion  varchar(100),
	SoftwareInstallDate  varchar(100),
	SoftwareInstallLocation varchar(max),
	SoftwareInstallSource varchar(max)
);

go

