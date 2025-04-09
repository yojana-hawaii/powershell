use DaHubInventory
go
--drop table if exists dbo.WorkstationSoftware
go
create table dbo.WorkstationSoftware
(
	ComputerName varchar(50),
	SoftwareName varchar(100),
	SoftwareVendor  varchar(100) ,
	SoftwareVersion  varchar(100),
	SoftwareInstallDate  date,
	SoftwareInstallLocation varchar(100),
	SoftwareInstallSource varchar(100),
	SoftwareScanSuccessDate datetime,
)
go 
select * from dbo.WorkstationSoftware
go