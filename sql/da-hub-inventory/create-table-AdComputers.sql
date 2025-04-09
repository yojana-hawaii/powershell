
use DaHubInventory
go

--drop table if exists dbo.AdComputers;
go 

create table dbo.AdComputers
(
	ComputerName varchar(50) ,

    Enabled bit,
    HasBitlocker bit,
    Haslaps bit,

	DistinguishedName varchar(100),
    OU varchar(100),
    sAMAccountName varchar(50),
    IPV4Address varchar(20),
	OperatingSystem varchar(50),
    OperatingSystemVersion varchar(50),
    Description varchar(500),
    UserAccountControl varchar(100),

    CreatedDate datetime,
	ModifiedDate datetime,
    BitLockerPasswordDate datetime,
    LapsExpirationDate datetime,
    LastLogonDate datetime,

    LogonCount int,

	AdComputerScanSuccessDate datetime
);

go

select * from dbo.AdComputers;
go