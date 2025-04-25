use DaHubInventory
go

drop proc if exists dbo.spGetUserEmail;

go

create proc dbo.spGetUserEmail
(
	@firstname varchar(50),
	@lastname varchar(50)
)
as 
begin

	select FirstName, LastName, emailAddress, case when CanonicalName like '%behavorial%' or title like '%BH%' then 1 else 0 end BH
	from DaHubInventory.dbo.AdUsers
	where FirstName = @firstname
		and LastName = @lastname

end

go
exec dbo.spGetUserEmail 'x', 'y'
go