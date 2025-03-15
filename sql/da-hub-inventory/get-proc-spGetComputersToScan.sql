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

	select top (@cnt) ad.ComputerName
	from DaHubInventory.dbo.AdComputers ad
		left join DaHubInventory.dbo.WorkstationSpecs ws on ad.ComputerName = ws.ComputerName
	where 
		ad.Enabled = 1
		and (datediff(day,ws.ScanSuccessDate,@date) >= @scanAfter
				or ws.ScanSuccessDate is null 
				/*or something is wrong > mssing patch or missing bit locker or sentinel one etc*/
			)
end

go

exec dbo.spGetComputersToScan @scanAfterDays = 1;
