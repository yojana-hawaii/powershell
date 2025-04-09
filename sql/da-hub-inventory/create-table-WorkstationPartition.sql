
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
	PartitionScanSuccessDate datetime
)
go 
select * from dbo.WorkstationPartition
go
