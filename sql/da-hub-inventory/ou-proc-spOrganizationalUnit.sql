
use DaHubInventory
go
drop proc if exists dbo.spOrganizationalUnit;
go
create proc dbo.spOrganizationalUnit
(
	@CanonicalName			varchar(100),
	@Description			varchar(100) = null,
	@ou_created				datetime2,
	@ou_modified			datetime2,
	@ou_deleted				datetime2 = null,
	@DistinguishedName		varchar(100),
	@ManagedBy				varchar(100) = null,
	@ObjectGuid				varchar(100),
	@Owner					varchar(100) = null,
	@Group					varchar(100) = null,
	@ExtendedAcl			varchar(100) = null,
	@ExtendedAclCount		int = null,

	@ProtectiodFromAccidentalDeletion	bit,
	@AreAccessRulesProtected			bit,
	@AreAuditRulesProtected				bit,
	@AreAccessRulesCanonical			bit,
	@AreAuditRulesCanonical				bit,

	@last_modified	datetime2 = null
)
as 
begin
	set nocount on;

	if @last_modified is null 
	begin
		set @last_modified = sysdatetime();
	end;

	with [source] (CanonicalName,[Description],ou_created,ou_modified,ou_deleted,
					DistinguishedName,ManagedBy,ObjectGuid,[Owner],[Group],
					ExtendedAcl,ExtendedAclCount,
					ProtectiodFromAccidentalDeletion,
					AreAccessRulesProtected,AreAuditRulesProtected,
					AreAccessRulesCanonical,AreAuditRulesCanonical,
					last_modified
				) as 
		(
			select @CanonicalName,@Description,@ou_created,@ou_modified,@ou_deleted,
					@DistinguishedName,@ManagedBy,@ObjectGuid,@Owner,@Group,
					@ExtendedAcl,@ExtendedAclCount,
					@ProtectiodFromAccidentalDeletion,
					@AreAccessRulesProtected,@AreAuditRulesProtected,
					@AreAccessRulesCanonical,@AreAuditRulesCanonical,
					@last_modified
		)
	merge dbo.OrganizationalUnit with (holdlock) as target
		using [source] on [target].ObjectGuid = [source].ObjectGuid

	when matched and [target].ou_modified <> [source].ou_modified
		then update set 
			[target].CanonicalName = [source].CanonicalName,
			[target].[Description] = [source].[Description],
			[target].ou_created = [source].ou_created,
			[target].ou_modified = [source].ou_modified,
			[target].ou_deleted = [source].ou_deleted,
			[target].DistinguishedName = [source].DistinguishedName,
			[target].ManagedBy = [source].ManagedBy,
			[target].[Owner] = [source].[Owner],
			[target].[Group] = [source].[Group],
			[target].ExtendedAcl = [source].ExtendedAcl,
			[target].ExtendedAclCount = [source].ExtendedAclCount,
			[target].ProtectiodFromAccidentalDeletion = [source].ProtectiodFromAccidentalDeletion,
			[target].AreAccessRulesProtected = [source].AreAccessRulesProtected,
			[target].AreAuditRulesProtected = [source].AreAuditRulesProtected,
			[target].AreAccessRulesCanonical = [source].AreAccessRulesCanonical,
			[target].AreAuditRulesCanonical = [source].AreAuditRulesCanonical,
			[target].last_modified	= @last_modified

	when not matched then 
		insert(CanonicalName,[Description],ou_created,ou_modified,ou_deleted,
					DistinguishedName,ManagedBy,ObjectGuid,[Owner],[Group],
					ExtendedAcl,ExtendedAclCount,
					ProtectiodFromAccidentalDeletion,
					AreAccessRulesProtected,AreAuditRulesProtected,
					AreAccessRulesCanonical,AreAuditRulesCanonical,
					last_modified
				)
		values(@CanonicalName,@Description,@ou_created,@ou_modified,@ou_deleted,
					@DistinguishedName,@ManagedBy,@ObjectGuid,@Owner,@Group,
					@ExtendedAcl,@ExtendedAclCount,
					@ProtectiodFromAccidentalDeletion,
					@AreAccessRulesProtected,@AreAuditRulesProtected,
					@AreAccessRulesCanonical,@AreAuditRulesCanonical,
					@last_modified
				);

end
go

select * from DaHubInventory.dbo.OrganizationalUnit
go

