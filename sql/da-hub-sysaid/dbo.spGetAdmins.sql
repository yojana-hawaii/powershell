use DaHubAide
go
drop proc if exists dbo.spGetAdmins;
go
create proc dbo.spGetAdmins
(
	@days varchar(5) = -7
)
as
begin

	select distinct AssignedTo
	from dbo.fxn_RelevantTickets(@days)
end

go

exec DaHubAide.dbo.spGetAdmins;

go