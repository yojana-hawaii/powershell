use DaHubInventory
go

drop proc if exists dbo.spGetComputersWithHpScanner;
go
create proc dbo.spGetComputersWithHpScanner
as
begin

	select  w.ComputerName, w.SoftwareName, w.SoftwareVersion, w.SoftwareVendor
	from dbo.WorkstationSoftware w
		inner join dbo.AdComputers a on w.ComputerName = a.ComputerName and a.Enabled = 1 
	--where SoftwareName like 'hp scan%'
	where 
		SoftwareVendor like 'HP Inc.'
		and   (
				SoftwareName  = ('HP Scan Basic Device Software')
				or SoftwareName like '%s3%' 
				or SoftwareName like '%s4%'
			)
		and SoftwareName not like '%5000%'
		and datediff(day,SoftwareScanSuccessDate, getdate()) <= 10
	order by SoftwareName

end
go
exec dbo.spGetComputersWithHpScanner
go
