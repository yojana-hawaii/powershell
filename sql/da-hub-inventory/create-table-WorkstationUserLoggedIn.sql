
use DaHubInventory
go
--drop table if exists dbo.WorkstationUserLoggedIn
go
create table dbo.WorkstationUserLoggedIn
(
	ComputerName varchar(50),
	UserLoggedIn  varchar(100) null,
	UserLastLoggedInDate  datetime2 null,
	UserLoggedInScanSuccessDate datetime
)
go 
select * from dbo.WorkstationUserLoggedIn
go