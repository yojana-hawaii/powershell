use DaHubInventory
go

drop proc if exists dbo.spSetWorkstationWinRmStatus;
go

create proc dbo.spSetWorkstationWinRmStatus
(
	@ComputerName	varchar(50),
	@WinRmEnabled varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSpecs
	set
		ScanAttemptDate = @now,
		WinRmEnabled = convert(bit,@WinRmEnabled)
	where ComputerName = @ComputerName

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationSpecs (ComputerName, ScanAttemptDate, WinRmEnabled)
		select @ComputerName, @now,	convert(bit,@WinRmEnabled)
	end

end
go