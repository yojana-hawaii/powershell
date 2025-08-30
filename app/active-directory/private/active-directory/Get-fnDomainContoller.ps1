function Get-fnDomainController {
    [CmdletBinding()]
    param()
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Controller Names"
        return @((Get-ADDomainController -Filter *).Hostname)
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }
}
# Get-fnDomainController -Verbose
