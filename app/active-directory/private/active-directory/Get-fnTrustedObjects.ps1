function Get-fnTrustedObjects {
    [CmdletBinding()]
    param()
    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting trusted domain objects"
        return Get-ADTrust -Filter *
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
	    continue
    }
}

