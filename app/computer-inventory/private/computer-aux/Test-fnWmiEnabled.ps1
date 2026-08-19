function Test-fnWmiEnabled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $ErrorActionPreference = 'Stop'
        $wmi = Get-WmiObject -ComputerName $computerName -Class "win32_operatingsystem"
        Write-Information "WMI response: $wmi"
        Invoke-fnSpSetWorkstationWmiStatus -computerName $computerName -enabled "1"
        return $true
    }
    catch {
        Write-Information "Wmi Failed"
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
        Invoke-fnSpSetWorkstationWmiStatus -computerName $computerName -enabled "0"
        return $false
    }
}