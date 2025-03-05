use DaHubInventory
go

drop proc if exists dbo.spWorkstationSpecsOffline;
go

create proc dbo.spWorkstationSpecsOffline
(
	@ComputerName	varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSpecs
	set
		ScanAttemptDate = @now,
		[Offline] = 0
	where ComputerName = @ComputerName

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationSpecs (ComputerName, ScanAttemptDate, Offline)
		select @ComputerName, @now,	0
	end

end