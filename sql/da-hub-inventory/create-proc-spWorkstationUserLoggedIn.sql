

use DaHubInventory
go

drop proc if exists dbo.spWorkstationUserLoggedIn
go
create proc dbo.spWorkstationUserLoggedIn
(
	@ComputerName varchar(50) ,
	@UserLoggedIn  varchar(100) = null,
	@UserLastLoggedInDate  varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationUserLoggedIn
	set
		UserLastLoggedInDate = @UserLastLoggedInDate,
		UserLoggedInScanSuccessDate	= @now
	where ComputerName = @ComputerName and UserLoggedIn = @UserLoggedIn;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationUserLoggedIn(ComputerName, 
                UserLoggedIn, UserLastLoggedInDate,
                UserLoggedInScanSuccessDate)
		select @ComputerName,
            @UserLoggedIn, @UserLastLoggedInDate,
            @now
	end

end

go
select * from dbo.WorkstationUserLoggedIn
go