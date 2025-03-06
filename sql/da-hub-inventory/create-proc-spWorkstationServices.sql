use DaHubInventory
go

drop proc if exists dbo.spWorkstationServices
go
create proc dbo.spWorkstationServices
(
	@ComputerName varchar(50) ,
	@ServiceName varchar(50),
	@ServiceDisplayName varchar(50),
	@ServiceStatus varchar(50),
	@ServiceStartType varchar(50),
	@ServiceCanPauseAndContinue bit,
	@ServiceCanShutdown bit,
	@ServiceCanStop bit
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationServices
	set
		ServiceStatus = @ServiceStatus,
		ServiceDisplayName = @ServiceDisplayName,
		ServiceStartType = @ServiceStartType,
		ServiceCanPauseAndContinue = convert(bit, @ServiceCanPauseAndContinue),
		ServiceCanShutdown = convert(bit,@ServiceCanShutdown),
		ServiceCanStop = convert(bit,@ServiceCanStop),
		ScanSuccessDate	= @now
	where ComputerName = @ComputerName and ServiceName = @ServiceName;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationServices(ComputerName, ServiceName, ServiceDisplayName,ServiceStatus, ServiceStartType, ServiceCanPauseAndContinue, ServiceCanShutdown, ServiceCanStop, ScanSuccessDate)
		select @ComputerName,@ServiceName, @ServiceDisplayName,@ServiceStatus, @ServiceStartType, convert(bit, @ServiceCanPauseAndContinue), convert(bit,@ServiceCanShutdown), convert(bit,@ServiceCanStop), @now
	end

end

go
select * from dbo.WorkstationServices
go