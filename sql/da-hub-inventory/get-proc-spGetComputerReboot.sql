use DaHubInventory
go
drop proc if exists dbo.spGetComputerReboot;
go

create proc spGetComputerReboot(
	@frequency varchar(10) = 'weekly'
)
as begin

	if @frequency = 'daily'
	begin
		select ComputerName, IsThinClient, IsVm, IsServer, Offline
		from dbo.vwWorkstationScanOrder
		where IsNeverScanned = 0
			and (IsThinClient = 1 
				or ComputerName like '%rds%' )
		order by Offline
	end 

	if @frequency = 'weekly'
	begin
		;with u as (
			select 
				ComputerName, offline, IsDesktop, IsLaptop, IsThinClient, IsServer, IsVm, OperatingSystem,
				RebootOrder = 
						case when ComputerName = 'kphc-powershell' then 100 
							when Offline = 1 then 90
							when IsDesktop = 1 then 10
							when IsThinClient = 1 then 20
							when IsLaptop = 1 then 30
							when IsServer = 1 then 40
							when IsVm = 1 then 50
						end
			from dbo.vwWorkstationScanOrder
			where IsNeverScanned = 0
				and  (IsThinClient = 1 
					or ComputerName like '%rds%'
					or IsDesktop = 1
					or IsLaptop = 1 
					or isserver = 0 )
		)
		select * from u
		order by RebootOrder
	end


end
go

exec dbo.spGetComputerReboot @frequency = 'daily'
go

