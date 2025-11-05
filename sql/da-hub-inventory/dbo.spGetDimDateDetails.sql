use DaHubInventory
go
drop proc if exists dbo.spGetDimDateDetails;
go

create proc dbo.spGetDimDateDetails
(
	@date varchar(10) = null
)
as
begin
	set @date = isnull(@date, convert(varchar(10), convert(date, GetDate() ) ) )

	select *
	from dbo.dimDate d
	where d.Date = @date

end
go