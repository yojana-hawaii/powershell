use DaHubInventory
go

drop type if exists dbo.tvpAdGroups;
go
create type dbo.tvpAdGroups as table (
	CanonicalName varchar(500) ,
    sAMAccountName varchar(50),
    Name varchar(50),
    Mail varchar(50),
	DistinguishedName varchar(500),
    Description varchar(max),
    GroupCategory varchar(50),
    GroupScope varchar(50),
    CreatedDate datetime,
	ModifiedDate datetime
);

go

