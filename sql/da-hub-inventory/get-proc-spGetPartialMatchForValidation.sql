use DaHubInventory
go
drop proc if exists dbo.spGetPartialMatchForValidation;
go
create proc dbo.spGetPartialMatchForValidation
as 
begin

	select HmsaMemberId, HmsaName, HmsaDoB, HmsaAddr1, HmsaAddr2, 
	AthenaPid, p.[patient-name], p.[patient-dob], p.[patient-address1], p.[patient-address2], 
	MatchingCriteria, MatchBy
	from athenaone.dbo.[all-hmsa] h
		inner join athenaone.dbo.[all-patient-all-insurance] p on p.[patient-id] = h.AthenaPid
	where MatchBy like 'shiba-ai%' and (ShibaMatching is null or  ShibaMatching > dateadd(day, -7, getdate()) )
		and athenapid is not null
end

go

exec dbo.spGetPartialMatchForValidation
go

