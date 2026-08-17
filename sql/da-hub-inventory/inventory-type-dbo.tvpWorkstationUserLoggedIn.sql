
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationUserLoggedIn;
go
create type dbo.tvpWorkstationUserLoggedIn as table (
	ComputerName varchar(50),
	UserLoggedIn  varchar(100),
	UserLastLoggedInDate  varchar(100)
);

go

