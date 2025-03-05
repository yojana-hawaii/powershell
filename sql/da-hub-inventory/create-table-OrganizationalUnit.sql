
use DaHubInventory
go
set ansi_nulls on
go
set quoted_identifier on
go
drop table if exists dbo.OrganizationalUnit;
go
create table dbo.OrganizationalUnit
(
	ObjectGuid			varchar(100),
	CanonicalName		varchar(100),
	[Description]		varchar(100),
	ou_created			datetime2,
	ou_modified			datetime2,
	ou_deleted			datetime2,
	DistinguishedName	varchar(100),
	ManagedBy			varchar(100),
	[Owner]				varchar(100),
	[Group]				varchar(100),
	ExtendedAcl			varchar(100),
	ExtendedAclCount	int,

	ProtectiodFromAccidentalDeletion	bit,
	AreAccessRulesProtected				bit,
	AreAuditRulesProtected				bit,
	AreAccessRulesCanonical				bit,
	AreAuditRulesCanonical				bit,

	deleted				bit,
	created				datetime2(3) constraint df_organizational_unit_created default (sysdatetime()),
	last_modified		datetime2(3),
	constraint pk_organizational_unit primary key(ObjectGuid)
)
go

select * from dbo.OrganizationalUnit
go
