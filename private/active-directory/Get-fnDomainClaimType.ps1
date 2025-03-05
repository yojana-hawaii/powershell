
function Get-fnDomainClaimType {
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Claim Type"
        return Get-ADClaimType -Filter *
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) Failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainClaimType -Verbose
