use DaHubInventory
go

drop view if exists dbo.vwWorkstationScanOrder
go
create view dbo.vwWorkstationScanOrder
as

	with u as (
		select 
			ad.ComputerName, 
			ws.SerialNumber,
			ad.Enabled ActiveInAD,
			ws.Offline LastScanOffline,
			case when ws.scanattemptdate is null then null else datediff(hour, ws.scanattemptdate, getdate()) end LastScanAttemptHours,
			case when ws.scanattemptdate is null then null else datediff(day, ws.scanattemptdate, getdate()) end LastScanAttemptDays,
			case when ws.ScanSuccessDate is null then null else datediff(hour,  ws.ScanSuccessDate ,getdate()) end LastSuccessfulScanHours,
			case when ws.ScanSuccessDate is null then null else datediff(DAY,  ws.ScanSuccessDate ,getdate()) end LastSuccessfulScanDays,
			ws.ScanSuccessDate, ws.ScanAttemptDate,
			case when ws.LastRebootDate is null then null else datediff(DAY,  ws.LastRebootDate ,getdate()) end LastRebootDays,
			convert(date,ad.CreatedDate) AdCreatedDate,
			
			model,
			MacAddresses,
			ws.WinRmEnabled,
			ws.WmiEnabled,

			case when ws.ScanSuccessDate is null then 1 else 0 end IsNeverScanned,
			case when ad.LastLogonDate is null then null else datediff(day,  ad.LastLogonDate ,getdate()) end LastLogonDays,
			case when ws.LastSecurityUpdateDate is null then null else datediff(day,  ws.LastSecurityUpdateDate ,getdate()) end LastSecurityPatchDays,
			case when ws.LastSecurityUpdateDate is null then null else datediff(day,  ws.LastSecurityUpdateDate ,getdate()) end LastPatchDays,
			
			case when ad.OperatingSystem like '%server%' then 1 else 0 end IsServer, 
			case when ws.IsThinClient is null then -1 else ws.IsThinClient end IsThinClient , 
			case when ws.IsVm is null then -1 else ws.IsVm end IsVm, 
			
			ws.IsDesktop, ws.IsLaptop, 
			ws.IsVpn, 
			ad.HasBitlocker, ad.Haslaps, 
			ad.IPV4Address,
			case 
				when ad.OperatingSystem like 'Windows 10%' then 'win-10'
				when ad.OperatingSystem like 'Windows 11%' then 'win-11'
				when ad.OperatingSystem like 'Windows Server 2022%' then 'server-2022'
				when ad.OperatingSystem like 'Windows Server 2016%' then 'server-2016'
				when ad.OperatingSystem like 'Windows Server 2019%' then 'server-2019'
				when ad.OperatingSystem like 'Windows Server 2003%' then 'server-2003'
				when ad.OperatingSystem like 'Windows Server 2012%' then 'server-2012'
				else ad.OperatingSystem
			end OperatingSystem, 
			ad.OU,
			case when sen.ServiceState = 'Running' or sen.ServiceState = '4' then 1 when sen.ServiceState is null then 0 else 0 end  SentinelOneService,
			case when kac.ServiceState = 'Running' or kac.ServiceState = '4' then 1 when kac.ServiceState is null then 0 else 0 end  KaceService,
			case when aid.ServiceState = 'Running' or aid.ServiceState = '4' then 1 when aid.ServiceState is null then 0 else 0 end  SysaidService,
			case when denc.ServiceState = 'Running' or denc.ServiceState = '4' then 1 when denc.ServiceState is null then 0 else 0 end  DellEncryptionService,
			case when cyl.ServiceState = 'Running' or cyl.ServiceState = '4' then 1 when cyl.ServiceState is null then 0 else 0 end  CylanceService,
			case when reg.ServiceState = 'Running' or reg.ServiceState = '4' then 1 when reg.ServiceState is null then 0 else 0 end  RemoteRegistryService,
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
			ws.DiskType, ws.DiskSizeGb, RamInstalledGb, RamUpgradableGb, RamSlotTotal, RamSlotUsed,
			ad.location,
			replace(replace(replace([Processor],'Intel(R) Core(TM)',''),'Intel(R) Celeron(R) ',''),'Intel(R) Xeon(R) ','') Processor
			

			

		from DaHubInventory.dbo.AdComputers ad
			left join DaHubInventory.dbo.WorkstationSpecs ws on ad.ComputerName = ws.ComputerName 
			left join DaHubInventory.dbo.WorkstationServices sen on ad.ComputerName = sen.ComputerName and sen.ServiceName = 'SentinelAgent'
			left join DaHubInventory.dbo.WorkstationServices kac on ad.ComputerName = kac.ComputerName and kac.ServiceName = 'konea'
			left join DaHubInventory.dbo.WorkstationServices aid on ad.ComputerName = aid.ComputerName and aid.ServiceName = 'SysAidAgent'
			left join DaHubInventory.dbo.WorkstationServices denc on ad.ComputerName = denc.ComputerName and denc.ServiceName = 'CMGShield'
			left join DaHubInventory.dbo.WorkstationServices cyl on ad.ComputerName = cyl.ComputerName and cyl.ServiceName like '%cylan%'
			left join DaHubInventory.dbo.WorkstationServices reg on ad.ComputerName = reg.ComputerName and reg.ServiceName like 'remoteregistry'
		where 
			ad.Enabled = 1
			and ad.OperatingSystem is not null --2 nas & a nimble
			and ad.ComputerName not like '%cluster%'
			and ad.OperatingSystem != 'unknown' -- 5 vCenter & vSphere
			and ad.OperatingSystem not in ('Windows Server 2003','Windows Server 2012 R2 Standard', 'server-2012', 'server-2003')
	)
		select 
			case when isnull(LastSuccessfulScanDays,7) <= 6 then isnull(LastSuccessfulScanDays,7) else 7 end
			+ IsNeverScanned*2 + isnull(IsLaptop,0)
			+ case when isnull(OperatingSystem,'') in ('server-2003','server-2012') then -100 else 0 end 
			testOrder,
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
			when OperatingSystem in ('Windows Server 2003','Windows Server 2012 R2 Standard', 'server-2012', 'server-2003') then -1000  -- unaccessible
			when IPV4Address is null then -7 -- unaccessible
			when IsThinClient = 1 then -1000
			when IPV4Address like '10.10.%' then 1 -- maybe accessible
		else 0 end
		+ case when IsVm = 1 and ActiveInAD = 1 then -5 else 0 end 
		+ (IsNeverScanned *100)
		--isnull(lastlogondays,4) 
		--+ isnull(LastScanAttemptHours/5,3) 
		NextScanOrder,

		case
			when  (IsServer = 1) then '99-server'
			when  (IsVm = 1) then '98-user-vm'
			when  (IsThinClient = 1) then '97-thin'
			when IsNeverScanned = 1 then '09-scanned-never'

			when DellEncryptionService = 1 then ('01-dell-encryption' + case when IsSdd = 0 then ', not-ssd' else '' end)


			when ComputerName like '%kace%' and IsDesktop = 1 then '10-kace-workstation'

			when OperatingSystem = 'win-11' and KaceService = 1 and SentinelOneService = 1 
					and HasBitlocker = 1 and IsSdd = 1 and SysaidService = 1 
					then '999-good-win11-kace-sentinel-bitlocker-ssd-sysaid'

			when (HasBitlocker = 0 or SentinelOneService = 0 or KaceService = 0 or IsSdd = 0 or SysaidService = 0) and OperatingSystem = 'win-11' then '02 ' 
				+ case when HasBitlocker = 0 then ', bitlocker' else '' end
				+ case when SentinelOneService = 0 then ', sentinel-one' else '' end 
				+ case when KaceService = 0 then ',kace' else '' end
				+ case when IsSdd = 0 then ', not-ssd' else '' end
				+ case when SysaidService = 0 then ', sysaid' else '' end
				+ case when OperatingSystem = 'win-11' then ', win-11' else '' end

			when (HasBitlocker = 0 or SentinelOneService = 0 or KaceService = 0 or IsSdd = 0 or SysaidService = 0) and OperatingSystem = 'win-10' then '03 ' 
				+ case when HasBitlocker = 0 then ', bitlocker' else '' end
				+ case when SentinelOneService = 0 then ', sentinel-one' else '' end 
				+ case when KaceService = 0 then ',kace' else '' end
				+ case when IsSdd = 0 then ', not-ssd' else '' end
				+ case when SysaidService = 0 then ', sysaid' else '' end
				+ case when OperatingSystem = 'win-10' then ', win-10' else '' end
				
			when OperatingSystem = 'win-10' then '06-win-10'
		end WorkPriority,
		case 
			when (IsVm = 1 or IsServer = 1) and LastSuccessfulScanDays <= 7 then '20-server-vm-scanned-7-days'
			when (IsVm = 1 or IsServer = 1) and LastSuccessfulScanDays > 7 then '05-server-vm-need-scan'

			when IsNeverScanned = 1 then '04-never-scanned'

			when IsThinClient = 1 and LastSuccessfulScanDays <= 7 then '19-thin-scanned-7-days'
			when IsThinClient = 1 and LastSuccessfulScanDays > 7 then '06-thin-need-scan'

			when IsDesktop = 1 and LastSuccessfulScanDays <= 7 then '18-desktop-scanned-7-days'
			when IsDesktop = 1 and LastSuccessfulScanDays > 7 then '01-desktop-need-scan'

			when IsLaptop = 1 and IsVpn = 1 and LastSuccessfulScanDays <= 30 then '17-laptop-vpn-scanned-30-days'
			when IsLaptop = 1 and IsVpn = 1 and LastSuccessfulScanDays > 30 then '02-laptop-vpn-need-scan'

			when IsLaptop = 1 and LastSuccessfulScanDays <= 30 then '16-laptop-scanned-30-days'
			when IsLaptop = 1 and LastSuccessfulScanDays > 30 then '03-laptop-need-scan'
		end ScannedStatus,
		case 
			when IsThinClient = 1 then 'thin-client'
			when DellEncryptionService = 1 then 'dell-encryption'

			when IsNeverScanned = 1 then 'never-scanned-' + OperatingSystem

			when IsDesktop = 1 and LastSuccessfulScanDays >= 7 then 'desktop-not-seen-7-days'
			when IsDesktop = 1 then 'desktop-' + OperatingSystem

			when IsLaptop = 1 and LastSuccessfulScanDays >= 30 then 'laptop-not-seen-30-days'
			when IsLaptop = 1  then 'laptop-' + OperatingSystem

			when IsServer = 1 and LastSuccessfulScanDays >= 7 then 'server-not-seen-7-days'
			when IsServer = 1 then OperatingSystem

			when IsVm = 1 and LastSuccessfulScanDays >= 7 then 'user-vm-not-seen-7-days'
			when IsVm = 1 then 'user-vm-' + OperatingSystem

		
		end [oct-2025-upgrade-status],
		*
		
		from u

go
select * 
from DaHubInventory.dbo.vwWorkstationScanOrder
order by testOrder desc
go
