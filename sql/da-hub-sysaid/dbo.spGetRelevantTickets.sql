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

	select
		f.Ticketnumber, f.TicketStatus, AssignedTo, f.TicketPriority, f.Category, 
		trim(replace(replace(replace(f.TicketSubject,'RE:',''),'FW:',''),'[EXTERNAL SENDER]','')) Subject, 
		SubmitUser,RequestUser,
		f.RequestTime, f.LastUpdate, f.ClosedTime,
		UpdateByEmail, UpdateInSysaid, UpdateByEmail7days, UpdateInSysaid7Days 
	from dbo.fxn_RelevantTickets(@days) f
		left join dbo.view_sysaidTicketSummary s on f.Ticketnumber = s.TicketNumber
	where AssignedTo = @admin or @admin = 'all' -- if no user get all
end

go

exec DaHubAide.dbo.spGetRelevantTickets @days = -7, @admin = 'all'
go