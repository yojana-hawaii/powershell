function Get-fnUpnSuffixes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Forest
    )
    Write-Verbose "Getting UPN Suffixes"
    return   @(
            [PSCustomObject]@{
                Name = $Forest.RootDomain
                Type = 'Primary/Default UPN'
            }
            foreach($upn in $Forest.UPSSuffixes){
                [PSCustomObject]@{
                 Name = $upn
                 Type = 'Secondary'
                }
            }
        )

}