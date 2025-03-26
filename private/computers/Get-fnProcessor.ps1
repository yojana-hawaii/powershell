function Get-fnProcessor {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory)]
       [string]$computerName 
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $processor = Get-CimInstance -Class Win32_Processor -ComputerName $computerName | Select-Object Name, NumberOfCores, NumberOfEnabledCore, CurrentClockSpeed
        $processorObject  = [PSCustomObject]@{
            Name = $processor.Name -join ", "
            NumberOfCores = $processor.NumberOfCores -join ", "
            NumberOfEnabledCore = $processor.NumberOfEnabledCore -join ", "
            CurrentClockSpeed = $processor.NumberOfCores -join ", "
        }
        return $processorObject
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $processor
}
