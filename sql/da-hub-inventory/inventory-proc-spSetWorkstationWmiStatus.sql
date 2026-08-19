use DaHubInventory
go

drop proc if exists dbo.spSetWorkstationWmiStatus;
go

create proc dbo.spSetWorkstationWmiStatus
(
	@ComputerName	varchar(50),
	@WmiEnabled varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	update dbo.WorkstationSpecs
	set
		ScanAttemptDate = @now,
		WmiEnabled = convert(bit,@WmiEnabled)
	where ComputerName = @ComputerName

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationSpecs (ComputerName, ScanAttemptDate, WmiEnabled)
		select @ComputerName, @now,	convert(bit,@WmiEnabled)
	end

end
go