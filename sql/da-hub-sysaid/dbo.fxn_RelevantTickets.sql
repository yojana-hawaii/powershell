
use DaHubAide
go
drop function if exists dbo.fxn_RelevantTickets;
go
create function dbo.fxn_RelevantTickets
(
	@days varchar(5) = -7
)
returns @retTable table
(
	Ticketnumber int null,
	TicketStatus varchar(50) null,
	TicketPriority varchar(50) null,
	Category varchar(100) null,
	SubCategory varchar(100) null,
	TicketSubject varchar(500) null,
	RequestTime datetime null,
	LastUpdate datetime null,
	ClosedTime datetime null,
	AssignedTo varchar(50) null,
	SubmitUser varchar(50) null,
	RequestUser varchar(50) null
)
as
begin

	declare @daysInt int 
	set @daysInt = convert(int, @days)

	declare @today date 
	set @today = convert(date,getdate())

	declare @relevantDate date 
	set @relevantDate = dateadd(day, @daysInt, @today)

	insert into @retTable	
	select
		Ticketnumber,TicketStatus,TicketPriority, 
		Category, SubCategory, TicketSubject, 
		RequestTime, LastUpdate, ClosedTime,AssignedTo, SubmitUser, RequestUser
	from dbo.view_sysaidTickets
	where
		RequestTime		>= @relevantDate 
		or ClosedTime	>= @relevantDate
		or LastUpdate	>= @relevantDate
		or TicketStatus not in ('Deleted', 'closed', 'Merge Closed')

	return 
end



go

select * from DaHubAide.dbo.fxn_RelevantTickets(-5)
go