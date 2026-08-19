use DaHubInventory
go

--drop table if exists dbo.WorkstationSpecs;
go
CREATE TABLE [dbo].[WorkstationSpecs](
	[ComputerName] [varchar](50) NULL,
	[SerialNumber] [varchar](100) NULL,
	[IsLaptop] [bit] NULL,
	[IsVpn] [bit] NULL,
	[IsThinClient] [bit] NULL,
	[IsVm] [bit] NULL,
	[IsServer] [bit] NULL,
	[IsDesktop] [bit] NULL,
	[BiosVersion] [varchar](50) NULL,
	[BiosReleaseDate] [date] NULL,
	[Manufacturer] [varchar](50) NULL,
	[Model] [varchar](50) NULL,
	[WakeUpType] [varchar](50) NULL,
	[CurrentUser] [varchar](50) NULL,
	[RamInstalledGb] [decimal](10, 2) NULL,
	[RamUpgradableGb] [decimal](10, 2) NULL,
	[RamSlotTotal] [int] NULL,
	[RamSlotUsed] [int] NULL,
	[Processor] [varchar](500) NULL,
	[NumberOfCores] [varchar](50) NULL,
	[NumberOfEnabledCore] [varchar](50) NULL,
	[CurrentClockSpeed] [varchar](50) NULL,
	[DiskModel] [varchar](1000) NULL,
	[DiskSizeGb] [varchar](500) NULL,
	[DiskType] [varchar](500) NULL,
	[TpmEnabled] [bit] NULL,
	[TpmVersion] [varchar](10) NULL,
	[MacAddresses] [varchar](300) NULL,
	[LastRebootDate] [datetime] NULL,
	[EncryptionLevel] [int] NULL,
	[OsArchitecture] [varchar](50) NULL,
	[NumberOfUsers] [int] NULL,
	[OsBuildNumber] [varchar](50) NULL,
	[OsBuildType] [varchar](50) NULL,
	[OsVersion] [varchar](50) NULL,
	[OsCountryCode] [varchar](50) NULL,
	[LastSecurityUpdateDate] [date] NULL,
	[LastSecurityUpdate] [varchar](50) NULL,
	[LastPatch] [varchar](50) NULL,
	[LastPatchDate] [date] NULL,

	[ScanSuccessDate] [datetime] NULL,
	[ScanAttemptDate] [datetime] NULL,
	[Offline] [bit] NULL,
	[WinRmEnabled] [bit] NULL,
	[WmiEnabled] [bit] NULL,
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null
) ON [PRIMARY]
GO


go

select top 10 * from dbo.WorkstationSpecs
go

/*
begin tran
alter table dbo.WorkstationSpecs
add
	IsCurrent bit not null default 1,
	EffectiveDate datetime not null default getdate(),
	ExpiryDate datetime null,
	RowHash varbinary(32),
	SlowlyChangingDimensionReason nvarchar(255) null

--commit
*/