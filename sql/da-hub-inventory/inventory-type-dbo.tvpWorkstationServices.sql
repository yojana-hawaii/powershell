
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationServices ;
go
create type dbo.tvpWorkstationServices as table (
	ComputerName varchar(50),
	ServiceName varchar(100),
	ServiceDisplayName varchar(max),
	ServiceState varchar(100),
	ServiceStartMode varchar(100),
	ServiceAcceptPause varchar(100),
	ServiceAcceptStop varchar(100),
	ServiceDelayedAutoStart varchar(100),
	ServiceStartName varchar(100)
);

go

