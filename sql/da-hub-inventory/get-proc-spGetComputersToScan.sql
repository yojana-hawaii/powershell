use DaHubInventory
go
drop proc if exists dbo.spGetComputersToScan;

go

create proc dbo.spGetComputersToScan(
	@count varchar(3) = 500,
	@scanAfterDays varchar(2) = 1,
	@scanAttemptHours varchar(2) = 1
)
as 
begin
	declare @cnt int = convert(int, @count);
	declare @datetime datetime = getdate();
	declare @date date = convert(date,@datetime );
	declare @scanAfter int = convert(int, @scanAfterDays );
	declare @attempAfter int = convert(int, @scanAttemptHours);
	
	select top (@cnt) 
		* 
	from dbo.vwWorkstationScanOrder vw
	where 
		(vw.ScanSuccessDate is null or datediff(day,vw.ScanSuccessDate,@date) >= @scanAfter )
		and (vw.scanattemptdate is null or datediff(hour, vw.scanattemptdate, @date) >= @attempAfter ) -- scan failure wait for 3 hours
	order by NextScanOrder desc
end

go

exec dbo.spGetComputersToScan @scanAfterDays = 2;
