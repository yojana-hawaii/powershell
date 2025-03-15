use DaHubInventory
go

drop proc if exists dbo.spGetComputersWithoutUser;
go
create proc dbo.spGetComputersWithoutUser (
	@count varchar(3) = 500,
	@username varchar(50)
)
as
begin
	declare @cnt int = convert(int, @count);


	drop table if exists #lapsCompleted
	select ComputerName 
	into #lapsCompleted
	from DaHubInventory.dbo.WorkstationLocalUsers lu 
	where LocalUserName = @username;

	select  top (@cnt) ad.ComputerName
	from DaHubInventory.dbo.AdComputers ad
		inner join DaHubInventory.dbo.WorkstationSpecs ws on ws.ComputerName = ad.ComputerName and ws.IsDesktop = 1
	where ad.Enabled = 1
		and ws.IsThinClient = 0 
		and ws.IsServer = 0
		and ad.ComputerName not in (select ComputerName from #lapsCompleted)
		

end

go
exec dbo.spGetComputersWithoutUser @count = 10, @username = 'admin'

go