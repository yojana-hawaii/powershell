function Test-fnWinRmEnabled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"

    $status = $false
    try {
        $ErrorActionPreference = 'Stop'
        $winrm = Test-WSMan -ComputerName $computerName 
        Write-Information "WinRm response: $winrm"

        Invoke-fnSpSetWorkstationWinRmStatus -computerName $computerName -enabled "1"
        $status = $true
    }
    catch {
        Write-Information "WinRm failed"
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
        Invoke-fnSpSetWorkstationWinRmStatus -computerName $computerName -enabled "0"
    }

    return $status
}
