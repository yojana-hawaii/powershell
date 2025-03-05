
function Get-fnDomainClaimTransformPolicy {
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Claim TransformPolicy"
        return Get-ADClaimTransformPolicy -Filter *
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) Failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainClaimTransformPolicy -Verbose