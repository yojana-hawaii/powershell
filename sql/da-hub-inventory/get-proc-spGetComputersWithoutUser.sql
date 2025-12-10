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

	select  top (@cnt)   vw.ComputerName, vw.LastScanOffline
	from DaHubInventory.dbo.vwWorkstationScanOrder vw 
	where vw.ComputerName not in (select ComputerName from #lapsCompleted)
		and vw.IsThinClient = 0
	order by NEWID()
		

end

go
exec dbo.spGetComputersWithoutUser @count = 500, @username = 'admin'

go