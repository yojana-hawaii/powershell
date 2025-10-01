
use DaHubInventory
go

drop proc if exists dbo.spGetComputerTaskList;
go
create proc dbo.spGetComputerTaskList
as
begin
	select *
	from DaHubInventory.dbo.vwWorkstationScanOrder w
end
go
exec DaHubInventory.dbo.spGetComputerTaskList;
go