


use DaHubInventory
go

--drop table if exists dbo.AdGroups;
go 

create table dbo.AdGroups
(
	CanonicalName varchar(500) ,
    sAMAccountName varchar(50),
    Name varchar(50),
    Mail varchar(50),
	DistinguishedName varchar(500),
    Description varchar(max),
    GroupCategory varchar(50),
    GroupScope varchar(50),
    CreatedDate datetime,
	ModifiedDate datetime,
    
	AdGroupScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
);

go

select * from DaHubInventory.dbo.AdGroups;
go


    

/*
begin tran
alter table dbo.AdGroups
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

--commit

*/