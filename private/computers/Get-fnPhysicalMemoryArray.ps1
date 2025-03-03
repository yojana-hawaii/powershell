function Get-fnPhysicalMemoryArray {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $mem = Get-WmiObject -Class win32_physicalMemoryArray -ComputerName $computerName |
                Select-Object @{
                    label = "RamSlotTotal"
                    expression = {$_.MemoryDevices}
                },
                @{
                    label = "RamUpgradableGb"
                    expression = {[Math]::Round($_.MaxCapacityEx / 1Gb, 2)}
                }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $mem
}