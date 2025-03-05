use DaHubInventory
go

drop proc if exists dbo.spWorkstationSpecs;
go

create proc dbo.spWorkstationSpecs
(
	@ComputerName varchar(50),
	@SerialNumber varchar(50),
	@BiosVersion varchar(50),
	@BiosReleaseDate varchar(50),
	@Manufacturer varchar(50),
	@Model varchar(50),
	@WakeUpType varchar(50),
	@CurrentUser varchar(50),
	@RamInstalledGb varchar(50),
	@RamUpgradableGb varchar(50),
	@RamSlotTotal varchar(50),
	@RamSlotUsed varchar(50),
	@Processor varchar(50),
	@NumberOfCores varchar(50),
	@NumberOfEnabledCore varchar(50),
	@CurrentClockSpeed varchar(50),
	@DiskModel varchar(50),
	@DiskSizeGb varchar(50),
	@DiskType varchar(50),
	@TpmEnabled varchar(50),
	@TpmVersion varchar(50),
	@MacAddresses varchar(50),
	@LastRebootDate varchar(50),
	@EncryptionLevel varchar(50),
	@OsArchitecture varchar(50),
	@NumberOfUsers varchar(50),
	@OsBuildNumber varchar(50),
	@OsBuildType varchar(50),
	@OsVersion varchar(50),
	@OsCountryCode varchar(50),
	@LastSecurityUpdateDate varchar(50),
	@LastSecurityUpdate varchar(50),
	@LastPatch varchar(50),
	@LastPatchDate varchar(50)
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
