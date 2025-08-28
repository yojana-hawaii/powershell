
use DaHubInventory
go
drop proc if exists dbo.spGetEmrIdFromBcbsId;
go

create proc dbo.spGetEmrIdFromBcbsId (
    @BcbsId varchar(50)
)
as
begin
    select AthenaPid
    from athenaone.dbo.[all-hmsa] 
    where HmsaMemberId = @BcbsId

end
go

exec dbo.spGetEmrIdFromBcbsId 'xxxx'

go

go