use DaHubInventory
go

drop proc if exists spWorkstationSpecs_Scd2;
go
create proc dbo.spWorkstationSpecs_Scd2
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
	set nocount on;
	declare @now datetime2 = getdate();

	begin try

		-- manually create temp table
		drop table if exists #sourceHashedParameter;
		create table #sourceHashedParameter (
			ComputerName varchar(50),
			IsLaptop varchar(50),
			IsVm varchar(50),
			IsVpn varchar(50),
			IsDesktop varchar(50),
			IsThinClient varchar(50),
			IsServer varchar(50),
			SerialNumber varchar(100),
			BiosVersion varchar(50),
			BiosReleaseDate varchar(50),
			Manufacturer varchar(50),
			Model varchar(50),
			WakeUpType varchar(50),
			CurrentUser varchar(50),
			RamInstalledGb varchar(50),
			RamUpgradableGb varchar(50),
			RamSlotTotal varchar(50),
			RamSlotUsed varchar(50),
			Processor varchar(500),
			NumberOfCores varchar(50),
			NumberOfEnabledCore varchar(50),
			CurrentClockSpeed varchar(50),
			DiskModel varchar(1000),
			DiskSizeGb varchar(50),
			DiskType varchar(50),
			TpmEnabled varchar(50),
			TpmVersion varchar(50),
			MacAddresses varchar(300),
			LastRebootDate varchar(50),
			EncryptionLevel varchar(50),
			OsArchitecture varchar(50),
			NumberOfUsers varchar(50),
			OsBuildNumber varchar(50),
			OsBuildType varchar(50),
			OsVersion varchar(50),
			OsCountryCode varchar(50),
			LastSecurityUpdateDate varchar(50),
			LastSecurityUpdate varchar(50),
			LastPatch varchar(50),
			LastPatchDate varchar(50),
			RowHash varbinary(32)
		);
		insert into #sourceHashedParameter (
			ComputerName,SerialNumber,
			IsDesktop,IsLaptop,IsVm,IsVpn,IsServer,IsThinClient,
			BiosVersion,BiosReleaseDate,Manufacturer,Model,WakeUpType,
			CurrentUser,RamInstalledGb,RamUpgradableGb,RamSlotTotal,RamSlotUsed,
			Processor,NumberOfCores,NumberOfEnabledCore,CurrentClockSpeed,
			DiskModel,DiskSizeGb,DiskType,TpmEnabled,TpmVersion,
			MacAddresses,LastRebootDate,EncryptionLevel,OsArchitecture,
			NumberOfUsers,OsBuildNumber,OsBuildType,OsVersion,
			OsCountryCode,LastSecurityUpdateDate,LastSecurityUpdate,LastPatch,LastPatchDate,
			RowHash
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
			convert(decimal(10,2), @RamInstalledGb),
			convert(decimal(10,2), @RamUpgradableGb),
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
			convert(varchar(10),@TpmVersion),
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
			convert(varchar(50),@LastSecurityUpdate),
			convert(varchar(50),@LastPatch),
			convert(date,@LastPatchDate),
			
			hashbytes('sha2_256',
				concat(
					lower(convert(varchar,isnull(@ComputerName,''))), 
					lower(convert(varchar,isnull(@SerialNumber,''))), 

					case when convert(bit,@IsDesktop) = 1 then '1' else '0' end, 
					case when convert(bit,@IsLaptop) = 1 then '1' else '0' end, 
					case when convert(bit,@IsVm) = 1 then '1' else '0' end, 
					case when convert(bit,@IsVpn) = 1 then '1' else '0' end, 
					case when convert(bit,@IsServer) = 1 then '1' else '0' end, 
					case when convert(bit,@IsThinClient) = 1 then '1' else '0' end, 

					lower(convert(varchar,isnull(@BiosVersion,''))), 
					lower(convert(varchar,isnull(@BiosReleaseDate,''))), 
					lower(convert(varchar,isnull(@Manufacturer,''))), 
					lower(convert(varchar,isnull(@Model,''))), 
					lower(convert(varchar,isnull(@WakeUpType,''))), 
					lower(convert(varchar,isnull(@CurrentUser,''))), 
					
					lower(convert(varchar,@RamInstalledGb)),
					lower(convert(varchar,@RamUpgradableGb)),
										
					lower(convert(varchar,isnull(@RamSlotTotal,''))),
					lower(convert(varchar,isnull(@RamSlotUsed,''))),
					lower(convert(varchar,isnull(@Processor,''))),
					lower(convert(varchar,isnull(@NumberOfCores,''))), 
					lower(convert(varchar,isnull(@NumberOfEnabledCore,''))), 
					lower(convert(varchar,isnull(@CurrentClockSpeed,''))), 
					lower(convert(varchar,isnull(@DiskModel,''))),
					lower(convert(varchar,isnull(@DiskSizeGb,''))),
					lower(convert(varchar,isnull(@DiskType,''))),
					case when convert(bit,@TpmEnabled) = 1 then '1' else '0' end, 
					lower(convert(varchar,isnull(@TpmVersion,''))),
					lower(convert(varchar,isnull(@MacAddresses,''))),
					lower(convert(varchar,convert(date,@LastRebootDate))),
					lower(convert(varchar,isnull(@EncryptionLevel,''))),
					lower(convert(varchar,isnull(@OsArchitecture,''))), 
					lower(convert(varchar,isnull(@NumberOfUsers,''))),
					lower(convert(varchar,isnull(@OsBuildNumber,''))), 
					lower(convert(varchar,isnull(@OsBuildType,''))), 
					lower(convert(varchar,isnull(@OsVersion,''))), 
					lower(convert(varchar,isnull(@OsCountryCode,'')))
					--lower(convert(varchar,isnull(@LastSecurityUpdateDate,''))), 
					--lower(convert(varchar,isnull(@LastSecurityUpdate,''))), 
					--lower(convert(varchar,isnull(@LastPatch,''))), 
					--lower(convert(varchar,isnull(@LastPatchDate,'')))
				)
			)
		;

		 --Guard: reject null
		if exists (select 1 from #sourceHashedParameter where ComputerName is null or SerialNumber is null)
		begin;
			throw 51001, 'Custom exception: ComputerName and SerialNumber canot be NULL',1;
		end;

		declare @reset int = 0;
		if @reset = 1
		begin
			 --Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
			begin try
				begin transaction;

				update ws
				set ws.IsCurrent = 0,
					ws.ExpiryDate = null,
					ws.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null && add-row-hash',
					RowHash = hashbytes('sha2_256',
								concat(
									lower(convert(varchar,isnull(ComputerName,''))), 
									lower(convert(varchar,isnull(SerialNumber,''))), 


									case when convert(bit,IsDesktop) = 1 then '1' else '0' end, 
									case when convert(bit,IsLaptop) = 1 then '1' else '0' end, 
									case when convert(bit,IsVm) = 1 then '1' else '0' end, 
									case when convert(bit,IsVpn) = 1 then '1' else '0' end, 
									case when convert(bit,IsServer) = 1 then '1' else '0' end, 
									case when convert(bit,IsThinClient) = 1 then '1' else '0' end, 

									lower(convert(varchar,isnull(BiosVersion,''))), 
									lower(convert(varchar,isnull(BiosReleaseDate,''))), 
									lower(convert(varchar,isnull(Manufacturer,''))), 
									lower(convert(varchar,isnull(Model,''))), 
									lower(convert(varchar,isnull(WakeUpType,''))), 
									lower(convert(varchar,isnull(CurrentUser,''))), 
										
									lower(convert(varchar,RamInstalledGb)),
									lower(convert(varchar,RamUpgradableGb)),
										
									lower(convert(varchar,isnull(RamSlotTotal,''))),
									lower(convert(varchar,isnull(RamSlotUsed,''))),
									lower(convert(varchar,isnull(Processor,''))),
									lower(convert(varchar,isnull(NumberOfCores,''))), 
									lower(convert(varchar,isnull(NumberOfEnabledCore,''))), 
									lower(convert(varchar,isnull(CurrentClockSpeed,''))), 
									lower(convert(varchar,isnull(DiskModel,''))),
									lower(convert(varchar,isnull(DiskSizeGb,''))),
									lower(convert(varchar,isnull(DiskType,''))),
									case when convert(bit,TpmEnabled) = 1 then '1' else '0' end, 

									lower(convert(varchar,isnull(TpmVersion,''))),
									lower(convert(varchar,isnull(MacAddresses,''))),

									lower(convert(varchar,convert(date,LastRebootDate))),
									lower(convert(varchar,isnull(EncryptionLevel,''))),
									lower(convert(varchar,isnull(OsArchitecture,''))), 
									lower(convert(varchar,isnull(NumberOfUsers,''))),
									lower(convert(varchar,isnull(OsBuildNumber,''))), 
									lower(convert(varchar,isnull(OsBuildType,''))), 
									lower(convert(varchar,isnull(OsVersion,''))), 
									lower(convert(varchar,isnull(OsCountryCode,'')))
									--lower(convert(varchar,isnull(LastSecurityUpdateDate,''))), 
									--lower(convert(varchar,isnull(LastSecurityUpdate,''))), 
									--lower(convert(varchar,isnull(LastPatch,''))), 
									--lower(convert(varchar,isnull(LastPatchDate,'')))
								)
							)
				from dbo.WorkstationSpecs ws;

				commit transaction;
			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;

	
			 --Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & computer-spec name tuple
			begin try
				begin transaction;

				;with cte as (
					select ws.*, 
						RowNum = ROW_NUMBER() over(partition by ComputerName, SerialNumber order by ScanSuccessDate desc) 
					from dbo.WorkstationSpecs ws
				
				) 
					update c	
						set c.IsCurrent = 1,
							c.SlowlyChangingDimensionReason = 'manual-step-0.2-activate-lastest-row->IsCurrent=1'
					from cte c
					where RowNum = 1;

				commit transaction;

			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;

			 --Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & computer-spec name tuple 
			begin try
				begin transaction;
					;with cte as (
						select wp.*, 
							RowNum = ROW_NUMBER() over(partition by ComputerName, SerialNumber order by ScanSuccessDate desc) 
						from dbo.WorkstationSpecs wp
				
					) 
						update c	
							set c.IsCurrent = 0,
								c.ExpiryDate = convert(date,getdate()),
								c.SlowlyChangingDimensionReason = 'manual-step-0.3-deactivate-old-record->add-expiry-date->IsCurrent=0-&&-expiration-date'
						from cte c
						where c.IsCurrent != 1

				commit transaction;
			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;



			 --count
			select SlowlyChangingDimensionReason, count(*) 
			from dbo.WorkstationSpecs
			group by SlowlyChangingDimensionReason;


		end
		;


		
		/* 6 possibility
			 scenario-1:one computer spec at a time
			 scenario-2:one computer spec at a time
			 scenario-3:hash-match-&&-IsCurrent=1->no-change
			 scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			 scenario 5: hash no match && IsCurrent=1 -> computer-spec status changed
			 step 5.1: change those to not current
			 step 5.2: insert new
			 scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
		*/
		;
		begin try 
			begin transaction;

			 --scenario-3:hash-match-&&-IsCurrent=1->no-change
			update dst	
				set ScanSuccessDate = @now,
					SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
			from dbo.WorkstationSpecs dst
				inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.SerialNumber = dst.SerialNumber and src.rowhash = dst.RowHash
			where dst.IsCurrent = 1
			;

			 --scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			;


			 --scenario 5: hash no match && IsCurrent=1 -> computer-spec status changed
			 --step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> computer-spec drive or IP changed -> set-IsCurrent=0 && add expiration date'
			from dbo.WorkstationSpecs dst
				inner join #sourceHashedParameter src on src.ComputerName = dst.ComputerName and src.SerialNumber = dst.SerialNumber 
			where dst.IsCurrent = 1
				and src.rowhash <> dst.RowHash
			;

			 --step 5.2: hash no-match -> removed old row -> now insert new
			insert into dbo.WorkstationSpecs(
					ComputerName,SerialNumber,
					IsDesktop,IsLaptop,IsVm,IsVpn,IsServer,IsThinClient,
					BiosVersion,BiosReleaseDate,Manufacturer,Model,WakeUpType,
					CurrentUser,RamInstalledGb,RamUpgradableGb,RamSlotTotal,RamSlotUsed,
					Processor,NumberOfCores,NumberOfEnabledCore,CurrentClockSpeed,
					DiskModel,DiskSizeGb,DiskType,TpmEnabled,TpmVersion,
					MacAddresses,LastRebootDate,EncryptionLevel,OsArchitecture,
					NumberOfUsers,OsBuildNumber,OsBuildType,OsVersion,
					OsCountryCode,LastSecurityUpdateDate,LastSecurityUpdate,LastPatch,LastPatchDate,
					ScanSuccessDate, ScanAttemptDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				ComputerName,SerialNumber,
				IsDesktop,IsLaptop,IsVm,IsVpn,IsServer,IsThinClient,
				BiosVersion,BiosReleaseDate,Manufacturer,Model,WakeUpType,
				CurrentUser,RamInstalledGb,RamUpgradableGb,RamSlotTotal,RamSlotUsed,
				Processor,NumberOfCores,NumberOfEnabledCore,CurrentClockSpeed,
				DiskModel,DiskSizeGb,DiskType,TpmEnabled,TpmVersion,
				MacAddresses,LastRebootDate,EncryptionLevel,OsArchitecture,
				NumberOfUsers,OsBuildNumber,OsBuildType,OsVersion,
				OsCountryCode,LastSecurityUpdateDate,LastSecurityUpdate,LastPatch,LastPatchDate,
				@now, @now,
				@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.WorkstationSpecs dst
						where dst.ComputerName = src.ComputerName
							and dst.SerialNumber = src.SerialNumber
							and dst.IsCurrent = 1
					)
			;

			 --scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			;
			

			commit transaction;
		end try
		begin catch
			if @@trancount > 0 rollback transaction;
			throw;
		end catch;
		;



	end try
	begin catch
		if @@trancount > 0 rollback transaction;
		throw;
	end catch

end 

go

select * from dbo.WorkstationSpecs
go



