

use DaHubInventory
go

drop proc if exists dbo.spAdGroups
go
create proc dbo.spAdGroups
(
	@CanonicalName varchar(50) ,
    @sAMAccountName varchar(50) = null,
	@Name varchar(50) = null,
	@mail varchar(50) = null,
	@DistinguishedName varchar(100) = null,
    @Description varchar(500) = null,
    @CreatedDate varchar(50) = null,
	@ModifiedDate varchar(50) = null,
	@GroupCategory varchar(50) = null,
	@GroupScope varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing groups
	update dbo.AdGroups
	set
		CanonicalName = @CanonicalName,
		Name = @Name,
		Mail = @mail,
		DistinguishedName = @DistinguishedName,
		Description = @Description,
		CreatedDate = convert(datetime, @CreatedDate),
		ModifiedDate = convert(datetime, @ModifiedDate),
		AdGroupScanSuccessDate = @now
	where sAMAccountName = @sAMAccountName;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.AdGroups(
				CanonicalName, sAMAccountName, Name, Mail, DistinguishedName, Description, CreatedDate, ModifiedDate, AdGroupScanSuccessDate
			)
		select @CanonicalName, @sAMAccountName, @Name, @mail, @DistinguishedName, @Description, @CreatedDate, @ModifiedDate,@now
	end

end

go
select * from dbo.AdGroups
go