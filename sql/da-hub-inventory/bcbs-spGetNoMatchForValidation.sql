

use DaHubInventory
go
drop proc if exists dbo.spGetNoMatchForValidation;
go
create proc dbo.spGetNoMatchForValidation
as 
begin

	select HmsaMemberId, HmsaName, HmsaDoB, HmsaGender, HmsaAddr1, HmsaAddr2, HmsaCity, HmsaSubscriberId, MatchingCriteria, MatchBy
	from athenaone.dbo.[all-hmsa] h
	where MatchingCriteria like '%no-match%'
end

go

exec dbo.spGetNoMatchForValidation
go