
use DaHubInventory
go

--drop table if exists dbo.AdGroupMembers;
go 

create table dbo.AdGroupMembers
(
    GroupSamAccountName varchar(50),
    Username varchar(50),
    ObjectClass varchar(50),
    
	AdGroupMemberScanSuccessDate datetime
);

go

select * from dbo.AdGroupMembers;
go

