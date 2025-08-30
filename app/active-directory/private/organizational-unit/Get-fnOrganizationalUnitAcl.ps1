function Get-fnOrganizationalUnitAcl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $DistinguishedName,
        [Parameter()]
        [string] $NetBiosName
    )
    
    $null           = New-PSDrive -name $NetBiosName -Root '' -PSProvider ActiveDirectory

    $acl            = Get-Acl -Path "$NetBiosName`:\$($DistinguishedName)" | Select-Object Owner, Group, AreAccessRulesProtected, AreAuditRulesProtected, AreAccessRulesCanonical, AreAuditRulesCanonical
    $extended       = Get-Acl -Path "$NetBiosName`:\$($DistinguishedName)" | Select-Object -ExpandProperty Access

    $ext = @()
    foreach($ex in $extended){
        $ext += $ex | Select-Object IdentityReference, `
                            IsInherited, InheritanceType, `
                            AccessControlType, `
                            InheritedObjectType, ActiveDirectoryRights, ObjectType,`
                            PropagationFlags , InheritanceFlags, ObjectFlags
    }
    $fullAcl = [ordered]@{
        Owner                       = $acl.Owner
        Group                       = $acl.Group
        AreAccessRulesProtected     = $acl.AreAccessRulesProtected
        AreAuditRulesProtected      = $acl.AreAuditRulesProtected
        AreAccessRulesCanonical     = $acl.AreAccessRulesCanonical
        AreAuditRulesCanonical      = $acl.AreAuditRulesCanonical
        Extended                    = $ext
        ExtendedCount               = $ext.Count
    }
    return $fullAcl 
}