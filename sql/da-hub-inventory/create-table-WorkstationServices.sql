use DaHubInventory
go

--drop table if exists dbo.WorkstationServices;
go 

create table dbo.WorkstationServices
(
	ComputerName varchar(50) ,
	ServiceName varchar(50),
	ServiceDisplayName varchar(50),
	ServiceStatus varchar(20),
	ServiceStartType varchar(20),
	ServiceCanPauseAndContinue bit,
	ServiceCanShutdown bit,
	ServiceCanStop bit,
	ServiceScanSuccessDate datetime
);

go

select * from dbo.WorkstationServices;
go