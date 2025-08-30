


use DaHubInventory
go

--drop table if exists dbo.AdGroups;
go 

create table dbo.AdGroups
(


	CanonicalName varchar(100) ,
    sAMAccountName varchar(50),
    Name varchar(50),
    Mail varchar(50),
	DistinguishedName varchar(100),
    Description varchar(500),
    GroupCategory varchar(50),
    GroupScope varchar(50),
    CreatedDate datetime,
	ModifiedDate datetime,
    
	AdGroupScanSuccessDate datetime
);

go

select * from dbo.AdGroups;
go