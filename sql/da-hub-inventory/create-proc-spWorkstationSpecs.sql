use DaHubInventory
go

drop proc if exists dbo.spWorkstationSpecs;
go

create proc dbo.spWorkstationSpecs
(
	@ComputerName varchar(50),
	@IsLaptop varchar(50),
	@IsVm varchar(50),
	@IsVpn varchar(50),
	@IsDesktop varchar(50),
	@IsThinClient varchar(50),
	@IsServer varchar(50),
	@SerialNumber varchar(100),
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
	@Processor varchar(500) = null,
	@NumberOfCores varchar(50) = null,
	@NumberOfEnabledCore varchar(50) = null,
	@CurrentClockSpeed varchar(50) = null,
	@DiskModel varchar(1000) = null,
	@DiskSizeGb varchar(50) = null,
	@DiskType varchar(50) = null,
	@TpmEnabled varchar(50) = null,
	@TpmVersion varchar(50) = null,
	@MacAddresses varchar(300) = null,
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

	-- If current VPN then update else keep old. Once VPN always VPN
	update dbo.WorkstationSpecs
	set IsVpn = 0
	where IsVpn is null and ComputerName = @ComputerName;
	update dbo.WorkstationSpecs
	set IsVpn = 1
	where @IsVpn = 1 and ComputerName = @ComputerName;
	
	--update existing Computers
	update dbo.WorkstationSpecs
	set
		SerialNumber = convert(varchar(50),@SerialNumber), 
		IsLaptop = convert(bit,@IsLaptop),
		IsDesktop = convert(bit,@IsDesktop),
		IsVm = convert(bit,@IsVm),
		IsServer = convert(bit,@IsServer),
		IsThinClient = convert(bit,@IsThinClient),
		BiosVersion = convert(varchar(50),@BiosVersion), 
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
		NumberOfCores = @NumberOfCores,
		NumberOfEnabledCore = @NumberOfEnabledCore, 
		CurrentClockSpeed = @CurrentClockSpeed, 
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
		[Offline] = 0
	where 
		ComputerName = @ComputerName;

	
	-- new entry
	 if @@ROWCOUNT = 0
	 begin
		insert into dbo.WorkstationSpecs
		(
			ComputerName,
			SerialNumber,
			IsDesktop,
			IsLaptop,
			IsVm,
			IsVpn,
			IsServer,
			IsThinClient,
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
			convert(varchar(50),@SerialNumber),
			convert(bit,@IsDesktop),
			convert(bit,@IsLaptop),
			convert(bit,@IsVm),
			convert(bit,@IsVpn),
			convert(bit,@IsServer),
			convert(bit,@IsThinClient),
			convert(varchar(50),@BiosVersion),
			convert(date,@BiosReleaseDate),
			convert(varchar(50),@Manufacturer),
			convert(varchar(50),@Model),
			convert(varchar(50),@WakeUpType),
			convert(varchar(50),@CurrentUser),
			@RamInstalledGb,
			@RamUpgradableGb,
			convert(int,@RamSlotTotal),
			convert(int,@RamSlotUsed),
			convert(varchar(500),@Processor),
			convert(varchar(50),@NumberOfCores),
			convert(varchar(50),@NumberOfEnabledCore),
			convert(varchar(50),@CurrentClockSpeed),
			convert(varchar(1000),@DiskModel),
			convert(varchar(500),@DiskSizeGb),
			convert(varchar(500),@DiskType),
			convert(bit,@TpmEnabled),
			@TpmVersion,
			convert(varchar(300),@MacAddresses),
			convert(datetime,@LastRebootDate),
			convert(int,@EncryptionLevel),
			convert(varchar(50),@OsArchitecture),
			convert(int,@NumberOfUsers),
			convert(varchar(50),@OsBuildNumber),
			convert(varchar(50),@OsBuildType),
			convert(varchar(50),@OsVersion),
			convert(varchar(50),@OsCountryCode),
			convert(date, @LastSecurityUpdateDate),
			@LastSecurityUpdate,
			@LastPatch,
			convert(date,@LastPatchDate),
			@now,
			@now,
			0
	 end

end
go

select * from dbo.WorkstationSpecs
go