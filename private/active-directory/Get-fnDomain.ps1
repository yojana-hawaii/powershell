function Get-fnDomain {
    [CmdletBinding()]
    param()
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Getting information about the domain"
        Get-ADDomain -ErrorAction Stop

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)."
        continue
    }
}
# Get-fnDomain -Verbose

