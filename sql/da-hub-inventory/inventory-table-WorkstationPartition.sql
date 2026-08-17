
use DaHubInventory
go
--drop table if exists dbo.WorkstationPartition
go
create table dbo.WorkstationPartition
(
    ComputerName varchar(50),
	PartitionNumber int,
    DiskNumber int,
    IsBoot bit,
    IsHidden bit,
    IsSystem bit,
    IsReadOnly bit,
    IsOffline bit,
    IsActive bit,
    DriveLetter varchar(2),
    PartitionSizeGb float,

	PartitionScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
)
go 
select top 10 * from dbo.WorkstationPartition
go

/*
alter table dbo.WorkstationPartition
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

*/