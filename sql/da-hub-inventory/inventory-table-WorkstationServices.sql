use DaHubInventory
go

--drop table if exists dbo.WorkstationServices;
go 

create table dbo.WorkstationServices
(
	Id int not null identity(1,1) primary key,
	ComputerName nvarchar(50) ,
	ServiceName nvarchar(100),
	ServiceDisplayName nvarchar(max),
	ServiceState nvarchar(100),
	ServiceStartMode nvarchar(100),
	ServiceAcceptPause bit,
	ServiceAcceptStop bit,
	ServiceDelayedAutoStart bit,
	ServiceStartName nvarchar(100),
	ServiceScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	IsDeleted bit not null default 0,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
) 
go
