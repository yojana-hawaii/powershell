
use DaHubInventory
go
drop proc if exists dbo.spActiveDirectory;
go
create proc dbo.spActiveDirectory 
(
	@name			varchar(100),
	@value			varchar(100) = null,
	@last_modified	datetime2 = null
)
as 
begin
	set nocount on;

	if @last_modified is null 
	begin
		set @last_modified = sysdatetime();
	end;


	with [source](name, value) as
		(
			select @name, @value
		)
	merge dbo.ActiveDirectory with (holdlock) as [target]
		using [source] on [target].name = [source].name
	when matched and [target].value <> [source].value
		then update set [target].value	= @value,
				[target].last_modified	= @last_modified
	when not matched then
		insert(name, value, last_modified)
		values(@name, @value, @last_modified);
	
end
go
select * from dbo.ActiveDirectory

/*test insert using stored procedure
exec dbo.active_directory_spInsert
	@name	 = 'a',
	@value = 'b';

go
select * from dbo.active_directory
go
exec dbo.active_directory_spInsert
	@name	= 'x',
	@value = 'y';

go
select * from dbo.active_directory
go
exec dbo.active_directory_spInsert
	@name	 = 'a',
	@value = 'c';
go
select * from dbo.active_directory;
go
*/
