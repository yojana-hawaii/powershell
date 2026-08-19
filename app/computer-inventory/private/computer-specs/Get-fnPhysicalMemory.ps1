function Get-fnPhysicalMemory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $mem = Get-CimInstance -Class Win32_PhysicalMemory -ComputerName $computerName | 
                    Select-Object *
        $cnt = [PSCustomObject]@{
            RamSlotUsed = if($null -eq $mem.Count){1} else {$mem.Count}
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $cnt
}