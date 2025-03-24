use DaHubInventory
go

drop table if exists dbo.WorkstationSpecs;
go
create table dbo.WorkstationSpecs
(
	ComputerName			varchar(50),
	SerialNumber			varchar(100), 
	IsLaptop				bit,
	IsVpn					bit,
	IsThinClient			bit,
	IsVm					bit,
	IsServer				bit,
	IsDesktop				bit,
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
	Processor				varchar(500), 
	NumberOfCores			varchar(50),
	NumberOfEnabledCore		varchar(50),
	CurrentClockSpeed		varchar(50),
	DiskModel				varchar(1000), 
	DiskSizeGb				varchar(500),
	DiskType				varchar(500), 
	TpmEnabled				bit,
	TpmVersion				varchar(10),
	MacAddresses			varchar(300), 
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