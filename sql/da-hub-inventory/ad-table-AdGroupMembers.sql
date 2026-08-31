
use DaHubInventory
go

--drop table if exists dbo.AdGroupMembers;
go 

create table dbo.AdGroupMembers
(
    GroupSamAccountName varchar(50),
    Username varchar(50),
    ObjectClass varchar(50),
    
	AdGroupMemberScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
);

go

select top 10 * from DaHubInventory.dbo.AdGroupMembers;
go



/*
begin tran
alter table dbo.AdGroupMembers
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

--commit

*/