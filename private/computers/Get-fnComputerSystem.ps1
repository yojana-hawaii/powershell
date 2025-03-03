function fnLocal_WakeupType($pWakeUpType){
    $wake = ''
    switch($pWakeUpType){
        0 {$wake = 'Reserved'; break}
        1 {$wake = 'Other'; break}
        2 {$wake = 'Unknown'; break}
        3 {$wake = 'APM Timer'; break}
        4 {$wake = 'Modem Rind'; break}
        5 {$wake = 'LAN Remote'; break}
        6 {$wake = 'Power Switch'; break}
        7 {$wake = 'PCI PME#'; break}
        8 {$wake = 'AD Power Restored'; break}
        Default {$wake = $pWakeUpType}
    }
    return $wake
}
function Get-fnComputerSystem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $computerSystem = Get-WmiObject -Class win32_computersystem -ComputerName $computerName | 
                             Select-Object Manufacturer, Model, 
                             @{label = "WakeUpType"
                                expression = {fnLocal_WakeupType($_.WakeUpType)}
                            }, 
                             @{
                                label = "CurrentUser"
                                expression={$_.UserName} 
                            },
                             @{
                                label='RamInstalledGb'
                                expression= {[MATH]::Round(($_.TotalPhysicalMemory / 1Gb), 2)} 
                             }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $computerSystem
}
