
use DaHubAide

drop view if exists dbo.view_sysaidTickets
go
create view dbo.view_sysaidTickets
as

	select 
		distinct 
		v.value_caption TicketStatus, 
		s.Status TicketStatusOrder,
		Computer_Id,
		
		s.id TicketNumber,
		problem_type Category,  
		problem_sub_type SubCategory,
		title TicketTitle,
		
		case when responsibility = 'I.T.Admin' then 'unassigned' else lower(replace(responsibility,'kphc\','')) end AssignedTo, 
		case when update_user = 'I.T.Admin' then 'unassigned' else lower(replace(update_user,'kphc\','')) end LastUpdateuser, 
		case when submit_user = 'I.T.Admin' then 'unassigned' else lower(replace(submit_user,'kphc\','')) end SubmitUser, 
		case when request_user = 'I.T.Admin' then 'unassigned' else lower(replace(request_user,'kphc\','')) end RequestUser, 

		assigned_group AssignedGroup,

		s.insert_time RequestTime,
		s.update_time LastUpdate, 
		s.close_time ClosedTime, 
		s.version TotalTicketUpdates,
		description,
		notes TicketNotes
	from sysaid.ilient.dbo.service_req s
		left join sysaid.[ilient].[dbo].[cust_values] v on s.status = v.value_key and v.list_name = 'status'
	where (
			s.insert_time >= '2023-01-01' 
				or (
					s.insert_time > '2021-01-01' 
						and v.value_caption not in ('Closed','Merge Closed','Deleted') 
					) 
			)
			and v.value_caption not in ('Reopened by End User','Pending') -- pending seems to be duplicate with in progress. Reopen and reopened by user seem duplicate
go

select * from dbo.view_sysaidTickets
go