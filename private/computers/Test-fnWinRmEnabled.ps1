function Test-fnWinRmEnabled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $ErrorActionPreference = 'Stop'
        Test-WSMan -ComputerName $computerName 

        Invoke-fnSpWorkstationSpecWinRm -computerName $computerName -enabled "1"
        return $true
    }
    catch {
        Write-Information "WinRm failed"
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
        Invoke-fnSpWorkstationSpecWinRm -computerName $computerName -enabled "0"
        return $false
    }
}