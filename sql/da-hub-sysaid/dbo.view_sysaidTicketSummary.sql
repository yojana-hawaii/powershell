use DaHubAide

go

drop view if exists dbo.view_sysaidTicketSummary
go
create view dbo.view_sysaidTicketSummary
	as


	with sysaid_cnt as (
		select 
			distinct id id, update_user, title, h.description, notes, 
			convert(date, update_time) update_time
		from sysaid.[ilient].[dbo].[service_req_history] h
			inner join dbo.view_sysaidTickets s on s.TicketNumber = h.id
		where update_user != 'Email Integration' and status != 1 
	)
	, email_cnt as (
		select [id] id,[from_user] from_user, convert(date, msg_time) msg_time
		from sysaid.[ilient].[dbo].[service_req_msg] e
			inner join dbo.view_sysaidTickets s on s.TicketNumber = e.id
		where from_user not in ( 'SysAid Support','Email Integration') and method = 'email'
	)
	,  notes as (
		select id, Count(*) UpdateInSysaid
		from sysaid_cnt
		group by id
	)
	, notes7days as (
		select id,Count(*) UpdateInSysaid7Days
		from sysaid_cnt
		where datediff(day,convert(date, getdate()), convert(date, update_time) ) >= -7
		group by id
	)
	, email as (
		select id,count(*) UpdateByEmail
		from email_cnt
		group by id
	)
	, email7days as (
		select [id],count(*) UpdateByEmail7days
		from email_cnt
		where datediff(day,convert(date, getdate()), convert(date, msg_time) ) >= -7
		group by id
	)
	select 
		isnull(e.id , n.id) TicketNumber, 
		--isnull(n.update_user, e.from_user) update_user, 
		isnull(UpdateByEmail,0) UpdateByEmail, 
		isnull(UpdateByEmail7days,0) UpdateByEmail7days, 
		isnull(UpdateInSysaid,0) UpdateInSysaid,
		isnull(UpdateInSysaid7Days,0) UpdateInSysaid7Days
	from notes n
		full outer join email e on e.id = n.id  --and e.from_user = n.update_user
		full outer join email7days e7 on e7.id = e.id  --and e7.from_user = e.from_user
		full outer join notes7days n7 on n7.id = n.id  --and n7.update_user = n.update_user

go

select * 
from DaHubAide.dbo.view_sysaidTicketSummary
order by UpdateByEmail7days desc, UpdateInSysaid7Days desc

			
