
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationPartitions;
go
create type dbo.tvpWorkstationPartitions as table (
	ComputerName varchar(50),
	PartitionNumber varchar(50),
    DiskNumber varchar(50),
    IsBoot varchar(50),
    IsHidden varchar(50),
    IsSystem varchar(50),
    IsReadOnly varchar(50),
    IsOffline varchar(50),
    IsActive varchar(50),
    DriveLetter varchar(50),
    PartitionSizeGb varchar(50)
);

go

