use DaHubInventory
go
drop proc if exists dbo.spGetWorkstationsToScan;

go

create proc dbo.spGetWorkstationsToScan(
	@count varchar(3) = 500,
	@scanAfterHours varchar(4) = 24,
	@scanAttemptHours varchar(4) = 1
)
as 
begin
	declare @cnt int = convert(int, @count);
	declare @datetime datetime = getdate();
	declare @date date = convert(date,@datetime );
	declare @scanAfter int = convert(int, @scanAfterHours );
	declare @attemptAfter int = convert(int, @scanAttemptHours);
	
	select top (@cnt) 
		NextScanOrder, ComputerName, SerialNumber, LastScanOffline, LastSuccessfulScanDays, LastScanAttemptHours
	from dbo.vwWorkstationScanOrder vw
	where 
		isnull(vw.LastSuccessfulScanHours,100) > @scanAfter
		and isnull(vw.LastScanAttemptHours,100) > @attemptAfter
		and IsThinClient != 1
		--(vw.ScanSuccessDate is null or datediff(day,vw.ScanSuccessDate,@date) >= @scanAfter )
		--and (vw.scanattemptdate is null or datediff(hour, vw.scanattemptdate, @date) >= @attempAfter ) -- scan failure wait for 3 hours
	order by NextScanOrder desc
end

go

exec dbo.spGetWorkstationsToScan;
