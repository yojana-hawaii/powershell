
use DaHubInventory
go

drop type if exists dbo.tvpWorkstationLocalUsers;
go
create type dbo.tvpWorkstationLocalUsers as table (
	ComputerName varchar(50),
	LocalUserName varchar(100),
	LocalUserStatus  varchar(100),
	LocalUserLocalAccount  bit,

	LocalUserPasswordExpires bit,
	LocalUserDisabled bit,
	LocalUserLockout bit,
	LocalUserPasswordChangeable bit,
	LocalUserPasswordRequired bit,

	LocalUserDescription varchar(500),
	LocalUserFullName  varchar(100),
	LocalUserAccountType varchar(100),

	LocalUserInstallDate date
);

go
