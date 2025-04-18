function Get-fnReadyForScan {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$computer
    )
    
    Write-Information "$($MyInvocation.MyCommand.Name): testing online and winrm active for $($computer)"

    # return false if computer offline > update database
    $ping = Test-Connection $computer -Quiet -Count 1
    if(-not $ping) {
        Invoke-fnSpWorkstationSpecsOffline -computerName $computer
        Write-Information "$computer offline"
        return $false
    }
    Write-Information "$computer is online"

    $winRm = Test-fnWinRmEnabled -computerName $computer
    $wmi = Test-fnWmiEnabled -computerName $computer
    write-information "$($MyInvocation.MyCommand.Name): Ping Status: $ping, WimRm Status: $winRm, Wmi Status: $wmi"

    # return false if both WMI and WinRm is unavailable
    if(-not $winRm -and -not $wmi){
        return
    }

    # Start WinRm and change it to start if Wmi is running
    $serviceName = "WinRM"
    if($wmi){
        Start-fnService -computerName $computer -serviceName $serviceName -finalState "Auto"
    }

    # return false if WinRm (WinrRm2) is still not running
    $winRm2 = Test-fnWinRmEnabled -computerName $computer
    if(-not $winRm2){
        write-information "$($MyInvocation.MyCommand.Name): Ping Status: $ping, WinRm Status: $winRm, Wmi Status: $wmi, WinRm: $WinRm2"
        return $false
    }

    return $true
}