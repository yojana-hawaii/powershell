use DaHubInventory
go


drop proc if exists dbo.spWorkstationServices
go
create proc dbo.spWorkstationServices
(
	@ComputerName varchar(50),
	@ServiceName varchar(50),
	@ServiceDisplayName varchar(50),
	@ServiceState varchar(50),
	@ServiceStartMode varchar(50),
	@ServiceAcceptPause varchar(50),
	@ServiceAcceptStop varchar(50),
	@ServiceDelayedAutoStart varchar(50),
	@ServiceStartName varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationServices
	set
		ServiceDisplayName = @ServiceDisplayName,
		ServiceState = @ServiceState,
		ServiceStartMode = @ServiceStartMode,
		ServiceAcceptPause = convert(bit, @ServiceAcceptPause),
		ServiceAcceptStop = convert(bit,@ServiceAcceptStop),
		ServiceDelayedAutoStart = convert(bit,@ServiceDelayedAutoStart),
		ServiceStartName = @ServiceStartName,
		ServiceScanSuccessDate	= @now
	where ComputerName = @ComputerName and ServiceName = @ServiceName;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationServices(ComputerName, ServiceName, ServiceDisplayName,
			ServiceState, ServiceStartMode, 
			ServiceAcceptPause, ServiceAcceptStop, ServiceDelayedAutoStart,
			ServiceStartName, ServiceScanSuccessDate)
		select @ComputerName,@ServiceName, @ServiceDisplayName,
			@ServiceState, @ServiceStartMode, 
			convert(bit, @ServiceAcceptPause), convert(bit,@ServiceAcceptStop), convert(bit,@ServiceDelayedAutoStart),
			@ServiceStartName, @now
	end

end

go
select * from dbo.WorkstationServices
go