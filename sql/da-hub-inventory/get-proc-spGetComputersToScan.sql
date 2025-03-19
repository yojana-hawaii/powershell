use DaHubInventory
go
drop proc if exists dbo.spGetComputersToScan;

go

create proc dbo.spGetComputersToScan(
	@count varchar(3) = 500,
	@scanAfterDays varchar(2) = 6
)
as 
begin
	declare @cnt int = convert(int, @count);
	declare @date date = convert(date,getdate() );
	declare @scanAfter int = convert(int, @scanAfterDays );
	
	select top (@cnt) 
		ad.ComputerName, 
		ws.ScanAttemptDate, ws.ScanSuccessDate, ws.LastPatchDate, ws.LastSecurityUpdateDate, 
		ad.HasBitlocker, ad.Haslaps, 
		sen.ServiceStatus SentinelOne,
		k.ServiceStatus Kace,
		aid.ServiceStatus Sysaid,
		dell.ServiceStatus DellEncryption,
		cyl.ServiceStatus Cylance
	from DaHubInventory.dbo.AdComputers ad
		left join DaHubInventory.dbo.WorkstationSpecs ws on ad.ComputerName = ws.ComputerName 
		left join DaHubInventory.dbo.WorkstationServices sen on ad.ComputerName = sen.ComputerName and sen.ServiceName = 'SentinelAgent'
		left join DaHubInventory.dbo.WorkstationServices k on ad.ComputerName = k.ComputerName and k.ServiceName = 'konea'
		left join DaHubInventory.dbo.WorkstationServices aid on ad.ComputerName = aid.ComputerName and aid.ServiceName = 'SysAidAgent'
		left join DaHubInventory.dbo.WorkstationServices dell on ad.ComputerName = dell.ComputerName and dell.ServiceName = 'CMGShield'
		left join DaHubInventory.dbo.WorkstationServices cyl on ad.ComputerName = cyl.ComputerName and cyl.ServiceName like '%cylan%'
	where 
		ad.Enabled = 1
		and (datediff(day,ws.ScanSuccessDate,@date) >= @scanAfter 
				or ws.ScanSuccessDate is null 
				or (ad.HasBitlocker = 0 and ws.IsServer = 0 and ws.IsThinClient = 0 and ws.IsVm = 0) --bitlocker not in server, thin client or vm
				or (ad.Haslaps = 0 and ws.IsThinClient = 0 ) -- laps not in thin client yet
				or DATEDIFF(day, ws.LastPatchDate, @date) >= 45
				or DATEDIFF(day, ws.LastSecurityUpdateDate, @date) >= 45
				or isnull(sen.ServiceStatus,'') != 'Running'
				or isnull(k.ServiceStatus,'') != 'Running'
				or isnull(aid.ServiceStatus,'') != 'Running'
				or isnull(dell.ServiceStatus,'') != 'Running'
				or cyl.ServiceStatus is not null
			)
		and datediff(hour, ws.scanattemptdate, @date) >= 3 -- scan failure wait for 3 hours
end

go

exec dbo.spGetComputersToScan @scanAfterDays = 3;
