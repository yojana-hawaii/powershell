function Test-fnWmiEnabled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $ErrorActionPreference = 'Stop'
        Get-WmiObject -ComputerName $computerName -Class "win32_operatingsystem"

        Invoke-fnSpWorkstationSpecWmi -computerName $computerName -enabled "1"
        return $true
    }
    catch {
        Write-Information "Wmi Failed"
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
        Invoke-fnSpWorkstationSpecWmi -computerName $computerName -enabled "0"
        return $false
    }
}
