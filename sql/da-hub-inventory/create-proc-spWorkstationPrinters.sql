use DaHubInventory
go

drop proc if exists dbo.spWorkstationPrinters
go
create proc dbo.spWorkstationPrinters
(
	@ComputerName varchar(50) ,
	@PrinterName varchar(50) = null,
	@PrinterShared  varchar(50) = null ,
	@PrinterShareName varchar(100) = null,
	@PrinterDriverName  varchar(50)  = null,
	@PrinterDriverVersion varchar(50)  = null,
	@PrinterIP varchar(50)  = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationPrinters
	set
		PrinterShared = @PrinterShared,
		PrinterShareName = @PrinterShareName,
        PrinterDriverName = @PrinterDriverName,
        PrinterDriverVersion = @PrinterDriverVersion,
        PrinterIP = @PrinterIP,
		PrinterScanSuccessDate	= @now
	where ComputerName = @ComputerName and PrinterName = @PrinterName;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationPrinters(ComputerName, 
                PrinterName, PrinterDriverName, PrinterDriverVersion, PrinterIP, PrinterShared,PrinterShareName,
                PrinterScanSuccessDate)
		select @ComputerName,
            @PrinterName, @PrinterDriverName, @PrinterDriverVersion, @PrinterIP, @PrinterShared,@PrinterShareName,
            @now
	end

end

go
select * from dbo.WorkstationPrinters
go