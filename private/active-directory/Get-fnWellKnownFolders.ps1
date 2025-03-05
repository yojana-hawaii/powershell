function Get-fnWellKnownFolders {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADDomain]$domain
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Well Known Folders"

    $WellKnownFolder = [ordered]@{
        UsersContainer              = $domain.UsersContainer
        ComputersContainer          = $domain.ComputersContainer
        DomainControllersContainer  = $domain.DomainControllersContainer
        DeletedObjectsContainer     = $domain.DeletedObjectsContainer
        SystemsContainer            = $domain.SystemsContainer
        LostAndFoundContainer       = $domain.LostAndFoundContainer
        QuotasContainer             = $domain.QuotasContainer
        ForeignSecurityPrincipalsContainer = $domain.ForeignSecurityPrincipalsContainer
    }
    return $WellKnownFolder
}