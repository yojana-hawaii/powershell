use DaHubInventory
go

drop proc if exists dbo.spWorkstationSpecs;
go

create proc dbo.spWorkstationSpecs
(
	@ComputerName varchar(50),
	@SerialNumber varchar(50),
	@BiosVersion varchar(50) = null,
	@BiosReleaseDate varchar(50) = null,
	@Manufacturer varchar(50) = null,
	@Model varchar(50) = null,
	@WakeUpType varchar(50) = null,
	@CurrentUser varchar(50) = null,
	@RamInstalledGb varchar(50) = null,
	@RamUpgradableGb varchar(50) = null,
	@RamSlotTotal varchar(50) = null,
	@RamSlotUsed varchar(50) = null,
	@Processor varchar(50) = null,
	@NumberOfCores varchar(50) = null,
	@NumberOfEnabledCore varchar(50) = null,
	@CurrentClockSpeed varchar(50) = null,
	@DiskModel varchar(50) = null,
	@DiskSizeGb varchar(50) = null,
	@DiskType varchar(50) = null,
	@TpmEnabled varchar(50) = null,
	@TpmVersion varchar(50) = null,
	@MacAddresses varchar(50) = null,
	@LastRebootDate varchar(50) = null,
	@EncryptionLevel varchar(50) = null,
	@OsArchitecture varchar(50) = null,
	@NumberOfUsers varchar(50) = null,
	@OsBuildNumber varchar(50) = null,
	@OsBuildType varchar(50) = null,
	@OsVersion varchar(50) = null,
	@OsCountryCode varchar(50) = null,
	@LastSecurityUpdateDate varchar(50) = null,
	@LastSecurityUpdate varchar(50) = null,
	@LastPatch varchar(50) = null,
	@LastPatchDate varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationSpecs
	set
		SerialNumber = @SerialNumber, 
		BiosVersion = @BiosVersion, 
		BiosReleaseDate = convert(date,@BiosReleaseDate), 
		Manufacturer = @Manufacturer, 
		Model = @Model, 
		WakeUpType = @WakeUpType, 
		CurrentUser = @CurrentUser, 
		RamInstalledGb = @RamInstalledGb, 
		RamUpgradableGb = @RamUpgradableGb, 
		RamSlotTotal = convert(int,@RamSlotTotal), 
		RamSlotUsed = convert(int,@RamSlotUsed), 
		Processor = @Processor, 
		NumberOfCores = convert(int,@NumberOfCores), 
		NumberOfEnabledCore = convert(int,@NumberOfEnabledCore), 
		CurrentClockSpeed = convert(int,@CurrentClockSpeed), 
		DiskModel = @DiskModel, 
		DiskSizeGb = @DiskSizeGb, 
		DiskType = @DiskType, 
		TpmEnabled = convert(bit,@TpmEnabled), 
		TpmVersion = @TpmVersion, 
		MacAddresses = @MacAddresses, 
		LastRebootDate = convert(datetime,@LastRebootDate), 
		EncryptionLevel = convert(int,@EncryptionLevel), 
		OsArchitecture = @OsArchitecture, 
		NumberOfUsers = convert(int,@NumberOfUsers), 
		OsBuildNumber = @OsBuildNumber, 
		OsBuildType = @OsBuildType, 
		OsVersion = @OsVersion, 
		OsCountryCode = @OsCountryCode, 
		LastSecurityUpdateDate = convert(date,@LastSecurityUpdateDate), 
		LastSecurityUpdate = @LastSecurityUpdate, 
		LastPatch = @LastPatch, 
		LastPatchDate = convert(date,@LastPatchDate),
		ScanSuccessDate = @now,
		ScanAttemptDate = @now,
		[Offline] = 1
	where 
		ComputerName = @ComputerName;

	
	-- new entry
	 if @@ROWCOUNT = 0
	 begin
		insert into dbo.WorkstationSpecs
		(
			ComputerName,
			SerialNumber,
			BiosVersion,
			BiosReleaseDate,
			Manufacturer,
			Model,
			WakeUpType,
			CurrentUser,
			RamInstalledGb,
			RamUpgradableGb,
			RamSlotTotal,
			RamSlotUsed,
			Processor,
			NumberOfCores,
			NumberOfEnabledCore,
			CurrentClockSpeed,
			DiskModel,
			DiskSizeGb,
			DiskType,
			TpmEnabled,
			TpmVersion,
			MacAddresses,
			LastRebootDate,
			EncryptionLevel,
			OsArchitecture,
			NumberOfUsers,
			OsBuildNumber,
			OsBuildType,
			OsVersion,
			OsCountryCode,
			LastSecurityUpdateDate,
			LastSecurityUpdate,
			LastPatch,
			LastPatchDate,
			ScanSuccessDate,
			ScanAttemptDate,
			[Offline]
		)
		select
			@ComputerName,
			@SerialNumber,
			@BiosVersion,
			convert(date,@BiosReleaseDate),
			@Manufacturer,
			@Model,
			@WakeUpType,
			@CurrentUser,
			@RamInstalledGb,
			@RamUpgradableGb,
			convert(int,@RamSlotTotal),
			convert(int,@RamSlotUsed),
			@Processor,
			convert(int,@NumberOfCores),
			convert(int,@NumberOfEnabledCore),
			convert(int,@CurrentClockSpeed),
			@DiskModel,
			@DiskSizeGb,
			@DiskType,
			convert(bit,@TpmEnabled),
			@TpmVersion,
			@MacAddresses,
			convert(datetime,@LastRebootDate),
			convert(int,@EncryptionLevel),
			@OsArchitecture,
			convert(int,@NumberOfUsers),
			@OsBuildNumber,
			@OsBuildType,
			@OsVersion,
			@OsCountryCode,
			convert(date, @LastSecurityUpdateDate),
			@LastSecurityUpdate,
			@LastPatch,
			convert(date,@LastPatchDate),
			@now,
			@now,
			1
	 end

end
go

select * from dbo.WorkstationSpecs
go