use DaHubInventory
go

--drop table if exists dbo.WorkstationServices;
go 

create table dbo.WorkstationServices
(
	ComputerName varchar(50) ,
	ServiceName varchar(50),
	ServiceDisplayName varchar(50),
	ServiceState varchar(50),
	ServiceStartMode varchar(50),
	ServiceAcceptPause bit,
	ServiceAcceptStop bit,
	ServiceDelayedAutoStart bit,
	ServiceStartName varchar(50),
	ServiceScanSuccessDate datetime
);

go

select * from dbo.WorkstationServices;
go