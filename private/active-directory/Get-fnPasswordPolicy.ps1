function Get-fnPasswordPolicy {
    [CmdletBinding()]
    param()
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Password Policy"
        return Get-ADDefaultDomainPasswordPolicy | 
            Select-Object ComplexityEnabled, LockoutDuration, LockoutObservationWindow, LockoutThreshold, `
                MaxPasswordAge, MinPasswordAge, MinPasswordLength, PasswordHistoryCount, ReversibleEncryptionEnabled                

        
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
     continue
     }
}
# Get-fnPasswordPolicy -Verbose