
use DaHubInventory
go
--drop table if exists dbo.WorkstationLocalUsers
go
create table dbo.WorkstationLocalUsers
(
	ComputerName varchar(50),
	LocalUserName varchar(100),
	LocalUserStatus  varchar(50),
	LocalUserLocalAccount  bit,

	LocalUserPasswordExpires bit,
	LocalUserDisabled bit,
	LocalUserLockout bit,
	LocalUserPasswordChangeable bit,
	LocalUserPasswordRequired bit,

	LocalUserDescription varchar(500),
	LocalUserFullName  varchar(100),
	LocalUserAccountType varchar(50),

	LocalUserInstallDate date,
    LocalUserScanSuccessDate datetime
)
go 
select * from dbo.WorkstationLocalUsers
go

