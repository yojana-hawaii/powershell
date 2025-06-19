
use DaHubAide

drop view if exists dbo.view_sysaidTickets
go
create view dbo.view_sysaidTickets
as

	select 
		distinct 
		case 
			when v.value_caption = 'Closed' or v.value_caption like 'on hold%' then replace(v.value_caption,'on hold','on-hold')
			else 'Open'
		end TicketStatus, 
		p.value_caption TicketPriority,
		Computer_Id,
		
		s.id TicketNumber,
		replace(replace(replace(replace(replace(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(problem_type,'01',''),'02',''),'03',''),'04',''),'05',''),'06',''),'07',''),'08',''),'09',''),'10',''),'11',''),'14',''),'15',''),'16',''),'19',''),'20 -','')),' use',''), ' issues',''),'Company ',''),' / ','/'),'/ ','/') Category,  
		problem_sub_type SubCategory,
		title TicketSubject,
		
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
		left join (
					select distinct value_key, value_caption  
					from sysaid.[ilient].[dbo].[cust_values] v 
					where v.list_name = 'status' 
				) v on s.status = v.value_key 
		left join (
					select distinct value_key, value_caption  
					from sysaid.[ilient].[dbo].[cust_values] v 
					where v.list_name = 'priority' 
				) p on s.priority = p.value_key
	where (
			s.insert_time >= '2023-01-01' and v.value_caption not in ('Merge Closed','Deleted') 
				--or (
				--	s.insert_time > '2021-01-01' 
				--		and v.value_caption not in ('Closed','Merge Closed','Deleted') 
				--	) 
			)
			--and v.value_caption not in ('Reopened by End User','Pending','Deleted','Merge Closed') -- pending seems to be duplicate with in progress. Reopen and reopened by user seem duplicate
go

select distinct Category  from DaHubAide.dbo.view_sysaidTickets --order by TicketStatus desc

--select *  from DaHubAide.dbo.view_sysaidTickets where TicketStatus not in ('Closed')
go