
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
	[Location] varchar(max),

    CreatedDate datetime,
	ModifiedDate datetime,
    BitLockerPasswordDate datetime,
    LapsExpirationDate datetime,
    LastLogonDate datetime,

    LogonCount int,

	AdComputerScanSuccessDate datetime,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
);

go

select AdComputerScanSuccessDate scaned, * from DaHubInventory.dbo.AdComputers where enabled = 1 order by AdComputerScanSuccessDate ;
go

/*
begin tran
alter table dbo.AdComputers
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

--commit

*/