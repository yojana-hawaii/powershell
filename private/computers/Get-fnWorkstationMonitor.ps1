function fnLocal_DecodeAscii{
    $value = ""
    if($args[0] -is [System.Array]){
        $value = [System.Text.Encoding]::ASCII.GetString($Args[0])
    } else {
       $value =  "ascii-descrypt-not-found"
    }
    return $value
}
function Get-fnWorkstationMonitor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $monitorIds = Get-CimInstance WmiMonitorId -namespace root\wmi -ComputerName $computerName | Select-Object ManufacturerName,UserFriendlyName,SerialNumberID, YearOfManufacture
        $videos = Get-CimInstance -Class Win32_VideoController -ComputerName $computerName | Select-Object deviceid, caption, VideoModeDescription
        $localMonitor = @() 
        $localVideo = @()
        $monitors = @()

        $counter = 1
        foreach($monitorId in $monitorIds){
            $localMonitor += [PSCustomObject]@{
                Name = $computerName
                MonitorManufacturer = fnLocal_DecodeAscii ($monitorId.ManufacturerName -notmatch 0)
                MonitorName = fnLocal_DecodeAscii ($monitorId.UserFriendlyName -notmatch 0)
                MonitorSerial = fnLocal_DecodeAscii ($monitorId.SerialNumberID -notmatch 0)
                MonitorYear = $monitorId.YearOfManufacture
                Counter = $counter
            }
            $counter += 1
        }

        $counter = 1
        foreach($video in $videos){
            $localVideo += [PSCustomObject]@{
                Name = $computerName
                DeviceID = $video.deviceid
                MonitorCaption = $video.caption
                MonitorResolution = $video.VideoModeDescription
                Counter = $counter
            }
            $counter += 1
        }

        $localMonitor | ForEach-Object {
            $currentCount = $_.Counter
            $currentVideo = $localVideo | Where-Object {$_.Counter -eq $currentCount}
            
            $monitors += [PSCustomObject]@{
                ComputerName = $_.Name
                MonitorManufacturer = $_.MonitorManufacturer
                MonitorName = $_.MonitorName
                MonitorSerial = $_.MonitorSerial
                MonitorYear = $_.MonitorYear
                MonitorCaption = $currentVideo.MonitorCaption
                MonitorResolution = $currentVideo.MonitorResolution
            }
        }
        return $monitors
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}