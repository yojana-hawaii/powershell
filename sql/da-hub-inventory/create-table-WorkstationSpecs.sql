use DaHubInventory
go

drop table if exists dbo.WorkstationSpecs;
go
create table dbo.WorkstationSpecs
(
	ComputerName			varchar(50),
	SerialNumber			varchar(50), 
	BiosVersion				varchar(50), 
	BiosReleaseDate			date,
	Manufacturer			varchar(50), 
	Model					varchar(50), 
	WakeUpType				varchar(50), 
	CurrentUser				varchar(50), 
	RamInstalledGb			decimal(10,2),
	RamUpgradableGb			decimal(10,2),
	RamSlotTotal			int,
	RamSlotUsed				int,
	Processor				varchar(50), 
	NumberOfCores			int,
	NumberOfEnabledCore		int,
	CurrentClockSpeed		int,
	DiskModel				varchar(50), 
	DiskSizeGb				decimal(10,2),
	DiskType				varchar(50), 
	TpmEnabled				bit,
	TpmVersion				varchar(10),
	MacAddresses			varchar(50), 
	LastRebootDate			datetime,
	EncryptionLevel			int,
	OsArchitecture			varchar(50), 
	NumberOfUsers			int,
	OsBuildNumber			varchar(50),
	OsBuildType				varchar(50), 
	OsVersion				varchar(50), 
	OsCountryCode			varchar(50), 
	LastSecurityUpdateDate	date,
	LastSecurityUpdate		varchar(50), 
	LastPatch				varchar(50), 
	LastPatchDate			date,
	ScanSuccessDate			datetime,
	ScanAttemptDate			datetime,
	[Offline]				bit

);

go

select * from dbo.WorkstationSpecs
go