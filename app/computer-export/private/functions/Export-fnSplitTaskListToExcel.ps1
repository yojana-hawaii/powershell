function Export-fnSplitTaskListToExcel {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Export computer data to excel"

    #try cath when there is possibility of exception
    try { 
        $now = Get-Date -Format "yyyyMMdd" 
        $srv = "Server-$now.$($param.extension)"
        $comp = "Workstation-$now.$($param.extension)"
        $serverPath = Join-Path -Path $($param.root) -ChildPath $srv
        $compPath = Join-Path -Path $($param.root) -ChildPath $comp

        $param.Server |
            Select-Object ComputerName, IPV4Address, OperatingSystem, AdCreatedDate, LastLogonDays,
                SentinelOneService, KaceService, CurrentUser, RamInstalledGb,
                LastSecurityPatchDays, LastPatchDays,
                LastScanOffline, LastSuccessfulScanDays, LastRebootDays |
            Sort-Object OperatingSystem, AdCreatedDate |
            Export-Excel -Path $serverPath -WorksheetName "Servers" -Autosize
        
        $param.UserVm |
            Select-Object ComputerName, IPV4Address, OperatingSystem, AdCreatedDate, LastLogonDays,
                SentinelOneService, KaceService, CurrentUser, RamInstalledGb,
                LastSecurityPatchDays, LastPatchDays,
                LastScanOffline, LastSuccessfulScanDays, LastRebootDays |
            Sort-Object OperatingSystem, AdCreatedDate | 
            Export-Excel -Path $serverPath -WorksheetName "User VM" -Autosize

        $param.Unscanned |
            Select-Object ComputerName, SerialNumber, AdCreatedDate, OperatingSystem |
            Sort-Object AdCreatedDate |
            Export-Excel -Path $compPath -WorksheetName "Not Scanned" -Autosize
        
        $param.OldEncryption |
            Select-Object ComputerName, SerialNumber, CurrentUser, Location, 
                TpmVersion, Processor, DiskType, DiskSizeGb, RamInstalledGb, RamSlotTotal, RamSlotUsed,
                IsDesktop, IsLaptop, IsVpn, AdCreatedDate, LastSuccessfulScanDays |
            Sort-Object AdCreatedDate |
            Export-Excel -Path $compPath -WorksheetName "Dell Encryption" -Autosize

        $param.Windows10 |
            Select-Object ComputerName, SerialNumber, CurrentUser, Location, 
                TpmVersion, Processor, DiskType, DiskSizeGb, RamInstalledGb, RamSlotTotal, RamSlotUsed,
                IsDesktop, IsLaptop, IsVpn, AdCreatedDate, LastSuccessfulScanDays |
            Sort-Object AdCreatedDate |
            Export-Excel -Path $compPath -WorksheetName "Win10" -Autosize

        $param.Windows11NeedWork |
            Select-Object ComputerName, WorkPriority, SerialNumber, CurrentUser, Location, 
                TpmVersion, Processor, DiskType, DiskSizeGb, RamInstalledGb, RamSlotTotal, RamSlotUsed,
                IsDesktop, IsLaptop, IsVpn, AdCreatedDate, LastSuccessfulScanDays |
            Sort-Object AdCreatedDate |
            Export-Excel -Path $compPath -WorksheetName "Win11 Incomplete" -Autosize

        $param.Windows11Good |
            Select-Object ComputerName, SerialNumber, LastPatchDays, LastSecurityPatchDays, LastRebootDays, CurrentUser, Location, 
                TpmVersion, Processor, DiskType, DiskSizeGb, RamInstalledGb, RamSlotTotal, RamSlotUsed,
                IsDesktop, IsLaptop, IsVpn, AdCreatedDate, LastSuccessfulScanDays |
            Sort-Object @{Expression="LastSecurityPatchDays"; Descending = $true}, 
                    @{Expression="LastPatchDays"; Descending = $true } |
            Export-Excel -Path $compPath -WorksheetName "Win11 Good" -Autosize
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}