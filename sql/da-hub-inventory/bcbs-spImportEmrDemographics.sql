


use DaHubInventory
go
drop proc if exists dbo.spImportEmrDemographics;
go
create proc dbo.spImportEmrDemographics
(
	@patientid varchar(100),
	@patientname varchar(100),
	@patientfirst varchar(100),
	@patientlast varchar(100),
	@patientdob varchar(100),
	@patientsex varchar(100),
	@patientaddress1 varchar(100),
	@patientaddress2 varchar(100),
	@patientcity varchar(100),
	@patientzip varchar(100),
	@patientlastseen varchar(100),
	@patientnextappt varchar(100),
	@patientguarantor varchar(100),
	@primaryinsurancename varchar(100),
	@primaryinsuranceid varchar(100),
	@primarypolicyholderid varchar(100),
	@primarypolicyholdername varchar(100),
	@secondaryinsurancename varchar(100),
	@secondaryinsuranceid varchar(100),
	@secondarypolicyholderid varchar(100),
	@secondarypolicyholdername varchar(100),
	@tertiaryinsurancename varchar(100),
	@tertiaryinsuranceid varchar(100),
	@tertiarypolicyholderid varchar(100),
	@tertiarypolicyholdername varchar(100)
)
as 
	begin
		declare @now datetime2 = getdate();

		with [source] (
				[patient-id],[patient-name],[patient-first],[patient-last],[patient-dob],[patient-sex],
				[patient-address1],[patient-address2],[patient-city],[patient-zip],
				[patient-last-seen],[patient-next-appt],[patient-guarantor],
				[primary-insurance-name],[primary-insurance-id],[primary-policy-holder-id],[primary-policy-holder-name],
				[secondary-insurance-name],[secondary-insurance-id],[secondary-policy-holder-id],[secondary-policy-holder-name],
				[tertiary-insurance-name],[tertiary-insurance-id],[tertiary-policy-holder-id],[tertiary-policy-holder-name]
			) as 
			(
			select @patientid,@patientname,@patientfirst,@patientlast,convert(date,@patientdob),@patientsex,
				@patientaddress1,@patientaddress2,@patientcity,@patientzip,
				convert(date,@patientlastseen),convert(date,@patientnextappt),@patientguarantor,
				@primaryinsurancename,@primaryinsuranceid,@primarypolicyholderid,@primarypolicyholdername,
				@secondaryinsurancename,@secondaryinsuranceid,@secondarypolicyholderid,@secondarypolicyholdername,
				@tertiaryinsurancename,@tertiaryinsuranceid,@tertiarypolicyholderid,@tertiarypolicyholdername
			)
		merge athenaone.dbo.[all-patient-all-insurance]  with (holdlock) as [target]
			using [source] on [source].[patient-id] = [target].[patient-id]
		
		when matched and 
			[target].[patient-name] <> [source].[patient-name]
			or [target].[patient-first] <> [source].[patient-first]
			or [target].[patient-last] <> [source].[patient-last]
			or isnull([target].[patient-dob],'') <> isnull([source].[patient-dob],'')
			or [target].[patient-sex] <> [source].[patient-sex]
			or [target].[patient-address1] <> [source].[patient-address1]
			or [target].[patient-address2] <> [source].[patient-address2]
			or [target].[patient-city] <> [source].[patient-city]
			or [target].[patient-zip] <> [source].[patient-zip]
			or isnull([target].[patient-last-seen],'') <> isnull([source].[patient-last-seen],'')
			or isnull([target].[patient-next-appt],'') <> isnull([source].[patient-next-appt],'')
			or [target].[patient-guarantor] <> [source].[patient-guarantor]
			or [target].[primary-insurance-name] <> [source].[primary-insurance-name]
			or [target].[primary-insurance-id] <> [source].[primary-insurance-id]
			or [target].[primary-policy-holder-id] <> [source].[primary-policy-holder-id]
			or [target].[primary-policy-holder-name] <> [source].[primary-policy-holder-name]
			or [target].[secondary-insurance-name] <> [source].[secondary-insurance-name]
			or [target].[secondary-insurance-id] <> [source].[secondary-insurance-id]
			or [target].[secondary-policy-holder-id] <> [source].[secondary-policy-holder-id]
			or [target].[secondary-policy-holder-name] <> [source].[secondary-policy-holder-name]
			or [target].[tertiary-insurance-name] <> [source].[tertiary-insurance-name]
			or [target].[tertiary-insurance-id] <> [source].[tertiary-insurance-id]
			or [target].[tertiary-policy-holder-id] <> [source].[tertiary-policy-holder-id]
			or [target].[tertiary-policy-holder-name] <> [source].[tertiary-policy-holder-name]

		then update set
			[target].[patient-name] = @patientname,
			[patient-first] = @patientfirst,
			[patient-last] = @patientlast,
			[patient-dob] = case when @patientdob = '' then null else convert(date,@patientdob) end,
			[patient-sex] = @patientsex,
			[patient-address1] = @patientaddress1,
			[patient-address2] = @patientaddress2,
			[patient-city] = @patientcity,
			[patient-zip] = @patientzip,
			[patient-last-seen] = case when @patientlastseen = '' then null else convert(date,@patientlastseen) end,
			[patient-next-appt] = case when @patientnextappt = '' then null else convert(date,@patientnextappt) end,
			[patient-guarantor] = @patientguarantor,
			[primary-insurance-name] = @primaryinsurancename,
			[primary-insurance-id] = @primaryinsuranceid,
			[primary-policy-holder-id] = @primarypolicyholderid,
			[primary-policy-holder-name] = @primarypolicyholdername,
			[secondary-insurance-name] = @secondaryinsurancename,
			[secondary-insurance-id] = @secondaryinsuranceid,
			[secondary-policy-holder-id] = @secondarypolicyholderid,
			[secondary-policy-holder-name] = @secondarypolicyholdername,
			[tertiary-insurance-name] = @tertiaryinsurancename,
			[tertiary-insurance-id] = @tertiaryinsuranceid,
			[tertiary-policy-holder-id] = @tertiarypolicyholderid,
			[tertiary-policy-holder-name] = @tertiarypolicyholdername,
			EmrModifiedDate = @now

	when not matched then
			insert (
				[patient-id],[patient-name],[patient-first],[patient-last],
				[patient-dob],
				[patient-sex],
				[patient-address1],[patient-address2],[patient-city],[patient-zip],
				[patient-last-seen],
				[patient-next-appt],
				[patient-guarantor],
				[primary-insurance-name],[primary-insurance-id],[primary-policy-holder-id],[primary-policy-holder-name],
				[secondary-insurance-name],[secondary-insurance-id],[secondary-policy-holder-id],[secondary-policy-holder-name],
				[tertiary-insurance-name],[tertiary-insurance-id],[tertiary-policy-holder-id],[tertiary-policy-holder-name],
				EmrAddedDate
			)
			values (@patientid,@patientname,@patientfirst,@patientlast,
				case when @patientdob = '' then null else convert(date,@patientdob) end,
				@patientsex,
				@patientaddress1,@patientaddress2,@patientcity,@patientzip,
				case when @patientlastseen = '' then null else convert(date,@patientlastseen) end,
				case when @patientnextappt = '' then null else convert(date,@patientnextappt) end,
				@patientguarantor,
				@primaryinsurancename,@primaryinsuranceid,@primarypolicyholderid,@primarypolicyholdername,
				@secondaryinsurancename,@secondaryinsuranceid,@secondarypolicyholderid,@secondarypolicyholdername,
				@tertiaryinsurancename,@tertiaryinsuranceid,@tertiarypolicyholderid,@tertiarypolicyholdername,
				@now
			);


end
go

select top 10 * from athenaone.dbo.[all-patient-all-insurance]
go