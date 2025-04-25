
use DaHubInventory
go

drop proc if exists dbo.spAdGroupMembers;
go

create proc dbo.spAdGroupMembers
(
    @GroupSamAccountName varchar(50),
    @Username varchar(50),
    @ObjectClass varchar(50)
)
as
begin
	
	declare @now datetime2 = getdate();

	update dbo.AdGroupMembers
	set
		AdGroupMemberScanSuccessDate = @now
	where 
		ObjectClass = @ObjectClass
		and GroupSamAccountName = @GroupSamAccountName
		and Username = @Username

	if @@ROWCOUNT = 0
	begin
		insert into dbo.AdGroupMembers( GroupSamAccountName,Username,ObjectClass, AdGroupMemberScanSuccessDate)
		select @GroupSamAccountName, @Username, @ObjectClass, @now
	end

end

go

select * 
from dbo.AdGroupMembers
go