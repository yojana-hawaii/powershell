function Get-fnDomainAuthPolicySilo {
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Authentication Policy Silo"
        return Get-ADAuthenticationPolicySilo -Filter '(name -like "AuthenticationPolicySilo*")'
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainAuthPolicySilo -Verbose