use DaHubInventory
go
set ansi_nulls on
go
set quoted_identifier on
go


drop table if exists dbo.ActiveDirectory;
go
create table dbo.ActiveDirectory 
(
	id				int identity(1,1),
	name			varchar(100),
	value			varchar(100),
	created			datetime2(3) constraint df_active_directory_created default (sysdatetime()),
	last_modified	datetime2(3),
	constraint pk_active_directory primary key (id)
)
go

select * from dbo.ActiveDirectory
go

/*testing last_modified -> directory to table
insert into dbo.active_directory (name, value, last_modified)
values ('a','b', sysdatetime())

go

select * from dbo.active_directory
go
update dbo.active_directory
set value = 'c', last_modified = SYSDATETIME()
where name = 'a'
go

select * from dbo.active_directory
*/
go
