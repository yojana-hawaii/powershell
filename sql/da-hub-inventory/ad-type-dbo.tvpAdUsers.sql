
use DaHubInventory
go

drop type if exists dbo.tvpAdUsers;
go
create type dbo.tvpAdUsers as table (
	CanonicalName varchar(max) not null, 
	sAMAccountName varchar(100) not null,
	userPrincipalName varchar(100),
	FirstName varchar(100),
	LastName varchar(100),
	DisplayName varchar(200),
	emailAddress varchar(100),
	DistinguishedName varchar(max),
	StreetAddress varchar(max),
	HomePhone varchar(100),
	MobilePhone varchar(100),
	OfficePhone varchar(100),
	Fax varchar(100),
	Company varchar(max),
	Department varchar(max),
	Title varchar(max),
	Description varchar(max),
	AccountExpirationDate datetime2,
	Enabled bit,
	LastLogonDate datetime2,
	CreatedDate datetime2,
	ModifiedDate datetime2,
	PasswordNeverExpires bit,
	PasswordExpired bit, 
	PasswordLastSetDate datetime2,
	ScriptPath varchar(100),
	LogonCount int,
	EmployeeId varchar(100),
	Manager varchar(max)
);

go

