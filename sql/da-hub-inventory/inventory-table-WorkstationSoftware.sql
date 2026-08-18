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
	SoftwareInstallLocation varchar(max),
	SoftwareInstallSource varchar(max),

	SoftwareScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
)
go 
select top 10 * from dbo.WorkstationSoftware
go


/*
alter table dbo.WorkstationSoftware
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
*/
