use DaHubInventory
go

drop type if exists dbo.tvpAdGroupMembers;
go
create type dbo.tvpAdGroupMembers as table (
	GroupSamAccountName varchar(50),
    Username varchar(50),
    ObjectClass varchar(50)
);

go

