use DaHubInventory
go

drop proc if exists dbo.spWorkstationSpecsWinRm;
go

create proc dbo.spWorkstationSpecsWinRm
(
	@ComputerName	varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSpecs
	set
		ScanAttemptDate = @now,
		winRmGood = 0
	where ComputerName = @ComputerName

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationSpecs (ComputerName, ScanAttemptDate, winRmGood)
		select @ComputerName, @now,	0
	end

end
go