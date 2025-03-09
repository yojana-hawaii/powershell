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
function fnLocal_isLaptop($ComputerName){

    $isLaptop = 0
    $chasis_type = Get-WmiObject -class win32_systemenclosure -computerName $ComputerName | select-object chassistypes
    $battery = Get-WmiObject -class win32_battery -ComputerName $ComputerName 

    # $battery + chassis
    $isLaptop = if ($chasis_type.chassistypes -eq 9 -or $chasis_type.chassistypes -eq 10 -or $chasis_type.chassistypes -eq 14 -or $battery )
                    {1}
                    else {0}
    
    return $isLaptop
}
function fnLocal_isDesktop($computername){
    $chasis_type = Get-WmiObject -class win32_systemenclosure -computerName $ComputerName | select-object chassistypes
    $isDesktop = if ($chasis_type.chassistypes -eq 3) {1} else {0}
    return $isDesktop
}
function fnLocal_isVpn(){
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$vpnIp
    )
    try{
        Write-Verbose "$($MyInvocation.MyCommand.Name): VPN check for $($computerName) with IP $($vpnIp)"
        $dns = Resolve-DnsName -Name $computerName
        $isVpn = if($dns.IPAddress -like "$vpnIp*" ){1}else{0}
        return $isVpn
    }catch{
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"

    }
}
function Get-fnComputerSystem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$vpnIp
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
                             },
                             @{
                                label = "isVM"
                                expression = {if ($_.Model -like 'virtual*' -or $_.Model -like "VMWare*") {1} else {0}}
                             },
                             @{
                                label = "isLaptop"
                                expression = {fnLocal_isLaptop($computerName)}
                             },
                             @{
                                label = "isThinClient"
                                expression = {if($_.Model -like '*wyse*') {1} else {0}}
                             },
                             @{
                                label = "isVpn"
                                expression = {fnLocal_isVpn -computerName $computerName -vpnIp $vpnIp}
                             }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $computerSystem
}