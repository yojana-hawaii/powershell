use DaHubInventory
go

drop proc if exists dbo.spGetUserAndManagerDetails;
go

create proc dbo.spGetUserAndManagerDetails
(
	@username varchar(50)
)
as
begin
	select 
		ad.sAMAccountName Username,
		ad.emailAddress, ad.DisplayName, ad.FirstName, ad.LastName,
		isnull(mngr.emailAddress,'') ManagerEmail, 
		isnull(mngr.FirstName,'') ManagerFirst,
		isnull(mngr.LastName,'') ManagerLast
	from dbo.AdUsers ad	
		left join dbo.AdUsers mngr on ad.Manager = mngr.sAMAccountName
	where ad.sAMAccountName = @username
end
go