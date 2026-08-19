use DaHubInventory
go

drop proc if exists dbo.spSetWorkstationOffline;
go

create proc dbo.spSetWorkstationOffline
(
	@ComputerName	varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSpecs
	set
		ScanAttemptDate = @now,
		[Offline] = 1
	where ComputerName = @ComputerName

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationSpecs (ComputerName, ScanAttemptDate, Offline)
		select @ComputerName, @now,	1
	end

end
go