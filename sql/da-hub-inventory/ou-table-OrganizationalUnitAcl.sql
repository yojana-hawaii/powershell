

use DaHubInventory
go
set ansi_nulls on
go
set quoted_identifier on
go
--drop table if exists dbo.OrganizationalUnitAcl;
go
create table dbo.OrganizationalUnitAcl
(
	ObjectGuid				varchar(100),

	IsInherited				bit,
	IdentityReference		varchar(100),
	InheritanceType			varchar(100),
	AccessControlType		varchar(100),
	InheritedObjectType 	varchar(100),
	ActiveDirectoryRights	varchar(100), 
	ObjectType            	varchar(100),
	PropagationFlags      	varchar(100),
	InheritanceFlags      	varchar(100),
	ObjectFlags           	varchar(100),

	deleted					bit,
	created					datetime2(3) constraint df_organizational_unit_acl_created default (sysdatetime()),
	last_modified			datetime2(3),
	constraint pk_organizational_unit_acl primary key(ObjectGuid, IdentityReference)
)
go

select * from DaHubInventory.dbo.OrganizationalUnitAcl
go
