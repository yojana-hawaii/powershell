use DaHubInventory
go

drop proc if exists dbo.spGetInsuranceMismatchForValidation;
go
create proc dbo.spGetInsuranceMismatchForValidation
as
begin
	-- demographics match but athena not does have insurance - recar-ai
	select AthenaPid, a.[patient-name], a.[patient-dob], [patient-last-seen], [patient-next-appt], HmsaSubscriberId, [primary-insurance-name] WrongInsuranceInAthena
	from athenaone.dbo.[all-patient-all-insurance] a
		inner join athenaone.dbo.[all-hmsa] h on h.AthenaPid = a.[patient-id]
	where  [primary-insurance-name] not like 'bcbs%'
			and [secondary-insurance-name] not like 'bcbs%'
			and [tertiary-insurance-name] not like 'bcbs%'
			and ([patient-next-appt] is not null or [patient-last-seen] is not null)

end

go

exec dbo.spGetInsuranceMismatchForValidation
go