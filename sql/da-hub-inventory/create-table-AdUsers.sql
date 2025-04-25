

use DaHubInventory
go

--drop table if exists dbo.AdUsers;
go 

create table dbo.AdUsers
(
	CanonicalName varchar(100) not null, 
	sAMAccountName varchar(50) not null,
	userPrincipalName varchar(50),
	FirstName varchar(50),
	LastName varchar(50),
	DisplayName varchar(50),
	emailAddress varchar(50),
	DistinguishedName varchar(100),
	StreetAddress varchar(50),
	HomePhone varchar(50),
	MobilePhone varchar(50),
	OfficePhone varchar(50),
	Fax varchar(50),
	Company varchar(50),
	Department varchar(50),
	Title varchar(50),
	Description varchar(500),
	AccountExpirationDate date,
	Enabled bit,
	LastLogonDate date,
	CreatedDate date,
	ModifiedDate date,
	PasswordNeverExpires bit,
	PasswordExpired bit, 
	PasswordLastSetDate date,
	ScriptPath varchar(50),
	LogonCount int,
	EmployeeId varchar(50),
	Manager varchar(50),
    
	AdUserScanSuccessDate datetime
);

go

select * from dbo.AdUsers;
go