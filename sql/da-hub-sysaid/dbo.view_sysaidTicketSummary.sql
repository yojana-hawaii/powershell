use DaHubAide

go

drop view if exists dbo.view_sysaidTicketSummary
go
create view dbo.view_sysaidTicketSummary
	as

	with notes as (
		select id id, update_user update_user,Count(*) UpdateInSysaid
		from sysaid.[ilient].[dbo].[service_req_history]
		where update_user != 'Email Integration' and status != 1 
		group by id, update_user
	)
	, email as (
		select [id] id,[from_user] from_user,count(*) UpdateByEmail
		from sysaid.[ilient].[dbo].[service_req_msg]
		where from_user not in ( 'SysAid Support','Email Integration')
			and method = 'email'
		group by id, from_user
	)
	select 
		isnull(e.id , n.id) TicketNumber, 
		isnull(update_user, from_user) update_user, 
		isnull(UpdateByEmail,0) UpdateByEmail, 
		isnull(UpdateInSysaid,0)UpdateInSysaid
	from notes n
		full outer join email e on e.id = n.id  and e.from_user = n.update_user

go

select * 
from dbo.view_sysaidTicketSummary

			
