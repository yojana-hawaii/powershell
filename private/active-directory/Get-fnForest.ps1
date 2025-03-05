function Get-fnForest {
[CmdletBinding()]
param()
    try{
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Getting information about the forest"
        return Get-ADForest -erroraction stop
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)."
        continue
    }
}
# Get-fnForest -Verbose
