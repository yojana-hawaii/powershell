use DaHubAide
go

drop proc if exists dbo.spGetRelevantTicketSumary
go

create proc dbo.spGetRelevantTicketSumary
(
	@days varchar(5) = -7,
	@admin varchar(50) = 'all'
)
as
begin

	select *
	from dbo.view_sysaidTicketSummary 
	where TicketNumber in (
			select Ticketnumber
			from dbo.fxn_RelevantTickets(@days)
			where AssignedTo = @admin or @admin ='all'
		)
end
go
exec dbo.spGetRelevantTicketSumary

go