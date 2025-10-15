use DaHubAide
go

drop proc if exists dbo.spGetSummaryForAll
go
create proc dbo.spGetSummaryForAll
(
	@days varchar(5) = -7
)
as
begin

	declare @cols nvarchar(max) = '', @query nvarchar(max) = '';

	--	declare @days varchar(5) = -7
	drop table if exists #tickets;
	select Ticketnumber, TicketStatus, AssignedTo 
	into #tickets
	from dbo.fxn_RelevantTickets(@days) 

	select @cols = @cols + QUOTENAME(TicketStatus) + ',' 
	from (select distinct TicketStatus from #tickets) as tmp

	select @cols = SUBSTRING(@cols, 0, len(@cols) ) -- remove trailing comma

	set @query = '
		select lower(AssignedTo) Admin, ' + @cols + '
		from (
			select Ticketnumber, TicketStatus, AssignedTo
			from #tickets
		) q
		pivot
		(
			count(Ticketnumber)
			for TicketStatus in (' + @cols + ')
		) pvt
		order by Admin
	'

	execute(@query)


end

go
exec DaHubAide.dbo.spGetSummaryForAll;
go