

function Get-fnDomainCentralAccessRule {
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Central Access Rule"
        return Get-ADCentralAccessRule -Filter *
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) Failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainCentralAccessRule -Verbose