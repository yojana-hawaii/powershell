use DaHubAide
go

drop proc if exists dbo.spGetRelevantTickets;
go
create proc dbo.spGetRelevantTickets
(
	@days varchar(5) = -7,
	@admin varchar(50) = 'all'
)
as
begin

	select * 
	from dbo.fxn_RelevantTickets(@days)
	where AssignedTo = @admin or @admin = 'all' -- if no user get all
end

go

exec dbo.spGetRelevantTickets @days = -7, @admin = 'all'
go