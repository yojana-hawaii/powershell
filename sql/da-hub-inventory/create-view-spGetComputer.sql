use DaHubInventory
go

drop view if exists dbo.vwWorkstationScanOrder
go
create view dbo.vwWorkstationScanOrder
as

	with u as (
		select 
			ad.ComputerName, 
			ad.Enabled,
			ws.Offline,
			ws.WinRmEnabled,
			ws.WmiEnabled,
			case when ws.scanattemptdate is null then null else datediff(hour, ws.scanattemptdate, getdate()) end LastScanAttemptHours,
			case when ws.scanattemptdate is null then null else datediff(day, ws.scanattemptdate, getdate()) end LastScanAttemptDays,
			case when ws.ScanSuccessDate is null then null else datediff(hour,  ws.ScanSuccessDate ,getdate()) end LastSuccessfulScanHours,
			case when ws.ScanSuccessDate is null then null else datediff(DAY,  ws.ScanSuccessDate ,getdate()) end LastSuccessfulScanDays,

			case when ws.LastRebootDate is null then null else datediff(DAY,  ws.LastRebootDate ,getdate()) end LastRebootDays,


			case when ws.ScanSuccessDate is null then 1 else 0 end IsNeverScanned,
			case when ad.LastLogonDate is null then null else datediff(day,  ad.LastLogonDate ,getdate()) end LastLogonDays,
			case when ws.LastSecurityUpdateDate is null then null else datediff(day,  ws.LastSecurityUpdateDate ,getdate()) end LastSecurityPatchDays,
			case when ws.LastSecurityUpdateDate is null then null else datediff(day,  ws.LastSecurityUpdateDate ,getdate()) end LastPatchDays,
			
			ws.IsServer, ws.IsDesktop, ws.IsLaptop, ws.IsThinClient, ws.IsVm, ws.IsVpn, 
			ad.HasBitlocker, ad.Haslaps, 
			ad.IPV4Address,
			ad.OperatingSystem, 
			ad.OU,

			case when sen.ServiceStatus = 'Running' then 1 when sen.ServiceStatus is null then null else 0 end  SentinelOneService,
			case when kac.ServiceStatus = 'Running' then 1 when kac.ServiceStatus is null then null else 0 end  KaceService,
			case when aid.ServiceStatus = 'Running' then 1 when aid.ServiceStatus is null then null else 0 end  SysaidService,
			case when denc.ServiceStatus = 'Running' then 1 when denc.ServiceStatus is null then null else 0 end  DellEncryptionService,
			case when cyl.ServiceStatus = 'Running' then 1 when cyl.ServiceStatus is null then null else 0 end  CylanceService,
			case 
				when ws.IsVm = 1 or ws.IsServer = 1 then null  
				when ws.DiskType = 'SDD' then 1 
				when ws.DiskType like '%SDD%' then 1
				when ws.DiskType is null then null 
				when ws.DiskType = '' then null 
			else 0 end IsSdd,
			ws.TpmEnabled,
			ws.TpmVersion,
			ws.CurrentUser,

			--ws.DiskType,
			--cyl.ServiceStatus Cylance,
			--denc.ServiceStatus DellEncryption,
			--aid.ServiceStatus Sysaid,
			--kac.ServiceStatus Kace,
			--sen.ServiceStatus SentinelOne,
			--ws.LastPatchDate, ws.LastSecurityUpdateDate, 
			ws.ScanSuccessDate, ws.ScanAttemptDate

			

		from DaHubInventory.dbo.AdComputers ad
			left join DaHubInventory.dbo.WorkstationSpecs ws on ad.ComputerName = ws.ComputerName 
			left join DaHubInventory.dbo.WorkstationServices sen on ad.ComputerName = sen.ComputerName and sen.ServiceName = 'SentinelAgent'
			left join DaHubInventory.dbo.WorkstationServices kac on ad.ComputerName = kac.ComputerName and kac.ServiceName = 'konea'
			left join DaHubInventory.dbo.WorkstationServices aid on ad.ComputerName = aid.ComputerName and aid.ServiceName = 'SysAidAgent'
			left join DaHubInventory.dbo.WorkstationServices denc on ad.ComputerName = denc.ComputerName and denc.ServiceName = 'CMGShield'
			left join DaHubInventory.dbo.WorkstationServices cyl on ad.ComputerName = cyl.ComputerName and cyl.ServiceName like '%cylan%'
		where 
			ad.Enabled = 1 
			and ad.OperatingSystem is not null --2 nas & a nimble
			and ad.OperatingSystem != 'unknown' -- 5 vCenter & vSphere
	)
		select 
		case
			when isnull(LastSuccessfulScanDays,6) > 3 
					and isnull(LastScanAttemptHours,6) > 3 
					and IPV4Address is not null 
					and IPV4Address not like '192%' 
					and OperatingSystem not in ('Windows Server 2003','Windows Server 2012 R2 Standard')
			then 100
			else 0
		end
		+
		case 
			when LastSuccessfulScanDays is null then 4
			when LastSuccessfulScanDays <=3 then LastSuccessfulScanDays
			else LastSuccessfulScanDays 
		end 
		+ 
		case
			when LastScanAttemptHours is null then 4
			when LastSuccessfulScanDays <= 3 then 0
			when LastScanAttemptHours <= 3 then -5
		else LastScanAttemptHours/10 end
		+ 
		case 
			when IPV4Address like '192%' then -10 -- unaccessible
			when OperatingSystem in ('Windows Server 2003','Windows Server 2012 R2 Standard') then -8  -- unaccessible
			when IPV4Address is null then -7 -- unaccessible
			when IsThinClient = 1 then -150
			when IPV4Address like '10.10.%' then 1 -- maybe accessible
		else 0 end
		+ IsNeverScanned
		--isnull(lastlogondays,4) 
		--+ isnull(LastScanAttemptHours/5,3) 
		NextScanOrder,
			* 
		from u

go
select * from DaHubInventory.dbo.vwWorkstationScanOrder
--where NextScanOrder >=3
order by NextScanOrder desc, LastSuccessfulScanHours
go