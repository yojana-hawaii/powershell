use DaHubInventory
go

drop proc if exists dbo.spGetOneComputerDetails;
go

create proc dbo.spGetOneComputerDetails(
	@computerName varchar(100)
)
as 
begin
	select * from dbo.vwWorkstationScanOrder
	where ComputerName = @computerName

end
go
