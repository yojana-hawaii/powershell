
use DaHubInventory
go
--drop table if exists dbo.WorkstationUserLoggedIn
go
create table dbo.WorkstationUserLoggedIn
(
	ComputerName varchar(50),
	UserLoggedIn  varchar(100) null,
	UserLastLoggedInDate  datetime2 null,
	UserLoggedInScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
)
go 
select top 10 * from DaHubInventory.dbo.WorkstationUserLoggedIn
go

/*
alter table dbo.WorkstationUserLoggedIn
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

*/