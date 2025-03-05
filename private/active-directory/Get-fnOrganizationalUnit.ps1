
function Get-fnOrganizationalUnit {
    [CmdletBinding()]
    param()

    try{
        $NetBiosName = (Get-fnDomain).NetBiosName
        $ouList = New-Object System.Collections.Generic.List[System.Object]
        
        $OUs = Get-ADOrganizationalUnit -Filter * -Properties * 
        foreach($ou in $OUs){
            Write-Verbose "$($MyInvocation.MyCommand.Name) working on $($ou.CanonicalName)"
            
            $acl = Get-fnOrganizationalUnitAcl -DistinguishedName $ou.DistinguishedName -NetBiosName $NetBiosName
            
            $ouDetails = [ordered]@{}
            $ouDetails.CanonicalName                    = $ou.CanonicalName
            $ouDetails.ProtectedFromAccidentalDeletion  = $ou.ProtectedFromAccidentalDeletion
            $ouDetails.Description                      = $ou.Description
            $ouDetails.Created                          = $ou.Created
            $ouDetails.Modified                         = $ou.Modified
            $ouDetails.Deleted                          = $ou.Deleted
            $ouDetails.DistinguishedName                = $ou.DistinguishedName
            $ouDetails.ManagedBy                        = $ou.ManagedBy
            $ouDetails.ObjectGuid                       = $ou.ObjectGuid
            $ouDetails.Owner                            = $acl.Owner
            $ouDetails.Group                            = $acl.Group
            $ouDetails.AreAccessRulesProtected          = $acl.AreAccessRulesProtected
            $ouDetails.AreAuditRulesProtected           = $acl.AreAuditRulesProtected
            $ouDetails.AreAccessRulesCanonical          = $acl.AreAccessRulesCanonical
            $ouDetails.AreAuditRulesCanonical           = $acl.AreAuditRulesCanonical
            $ouDetails.ExtendedAcl                      = $acl.Extended
            $ouDetails.ExtendedAclCount                 = $acl.ExtendedCount
            
            $ouList.Add( $ouDetails)
        }
    
        return $ouList
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
    
}
