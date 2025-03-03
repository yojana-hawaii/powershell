function Get-fnProcessor {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory)]
       [string]$computerName 
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $processor = Get-WmiObject -Class Win32_Processor -ComputerName $computerName | Select-Object Name, NumberOfCores, NumberOfEnabledCore, CurrentClockSpeed
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $processor
}
