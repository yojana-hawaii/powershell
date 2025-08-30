function Get-fnDomainAuthPolicy{
    [CmdletBinding()]
    param()

    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Domain Authentication Policy"
        return Get-ADAuthenticationPolicy -LDAPFilter '(name=AuthenticationPolicy*)'
    } catch {
        Write-Error "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
        continue
    }
}

# Get-fnDomainAuthPolicy -Verbose