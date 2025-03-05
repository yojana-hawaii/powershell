use DaHubInventory
go
drop proc if exists dbo.spOrganizationalUnitAcl;
go
create proc dbo.spOrganizationalUnitAcl
(
    @ObjectGuid				varchar(100)=null,

	@IsInherited			varchar(100),
	@IdentityReference		varchar(100)=null,
	@InheritanceType		varchar(100)=null,
	@AccessControlType		varchar(100)=null,
	@InheritedObjectType 	varchar(100)=null,
	@ActiveDirectoryRights	varchar(100)=null, 
	@ObjectType            	varchar(100)=null,
	@PropagationFlags      	varchar(100)=null,
	@InheritanceFlags      	varchar(100)=null,
	@ObjectFlags           	varchar(100)=null,
	@last_modified			varchar(10) = null
)
as 
begin
	set nocount on;

	if @last_modified is null 
	begin
		set @last_modified = sysdatetime();
	end;


    with [source] (ObjectGuid,IdentityReference, IsInherited, InheritanceType,AccessControlType,InheritedObjectType,
                    ActiveDirectoryRights, ObjectType, PropagationFlags, ObjectFlags,
					last_modified
				) as 
		(
			select @ObjectGuid,@IdentityReference, @IsInherited, @InheritanceType, @AccessControlType, @InheritedObjectType,
                    @ActiveDirectoryRights,@ObjectType, @PropagationFlags, @ObjectFlags,
					@last_modified
		)
	merge dbo.OrganizationalUnitAcl with (holdlock) as target
		using [source] on [target].ObjectGuid = [source].ObjectGuid and [target].IdentityReference = [source].IdentityReference

	when matched and [target].IsInherited				<> [source].IsInherited
					or [target].InheritanceType			<> [source].InheritanceType
					or [target].AccessControlType		<> [source].AccessControlType
					or [target].InheritedObjectType		<> [source].InheritedObjectType
					or [target].ActiveDirectoryRights	<> [source].IsInherited
					or [target].ObjectType				<> [source].ObjectType
					or [target].PropagationFlags		<> [source].PropagationFlags
					or [target].ObjectFlags				<> [source].ObjectFlags
		then update set 
			[target].last_modified	= @last_modified

	when not matched then 
		insert(ObjectGuid,IdentityReference, IsInherited, InheritanceType,AccessControlType,InheritedObjectType,
                    ActiveDirectoryRights, ObjectType, PropagationFlags, ObjectFlags,
					last_modified
				)
		values(@ObjectGuid,@IdentityReference, @IsInherited, @InheritanceType, @AccessControlType, @InheritedObjectType,
                    @ActiveDirectoryRights,@ObjectType, @PropagationFlags, @ObjectFlags,
					@last_modified
				);


end
go

select * from DaHubInventory.dbo.OrganizationalUnitAcl 
go