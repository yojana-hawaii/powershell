

function Get-fnDomainCentralAccessPolicy {
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Central Access Policy"
        return Get-ADCentralAccessPolicy -Filter *
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) Failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainCentralAccessPolicy -Verbose