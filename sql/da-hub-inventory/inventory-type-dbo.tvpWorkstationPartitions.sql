
use DaHubInventory
go

--drop type if exists dbo.tvpWorkstationPartitions;
go
create type dbo.tvpWorkstationPartitions as table (
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
    PartitionSizeGb float
);

go

