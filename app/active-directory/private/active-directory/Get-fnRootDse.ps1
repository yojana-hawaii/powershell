function Get-fnRootDse {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Getting information about the Root Dse"
        Get-ADRootDSE -Properties *
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    }
}

# Get-fnRootDse -Verbose