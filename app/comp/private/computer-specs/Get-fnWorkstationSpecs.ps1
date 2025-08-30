function Get-fnWorkstationSpecs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$vpnIp
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"

    $bios = (Get-fnBios -computerName $computerName)
    $system = (Get-fnComputerSystem -computerName $computerName -vpnIp $vpnIp)
    $memoryArray = (Get-fnPhysicalMemoryArray -computerName $computerName)
    $processor = (Get-fnProcessor -computerName $computerName)
    $disk = (Get-fnDisk -computerName $computerName)
    $tpm = (Get-fnTpm -computerName $computerName)
    $os = (Get-fnOperatingSystem -computerName $computerName)
    $hotfix = (Get-fnHotFix -computerName $computerName)

    $comp = [PSCustomObject]@{
        ComputerName        = $computerName
        SerialNumber        = $bios.SerialNumber
        BiosVersion         = $bios.BiosVersion
        BiosReleaseDate     = $bios.BiosReleaseDate
        Manufacturer        = $system.Manufacturer
        Model               = $system.Model
        WakeUpType          = $system.WakeUpType
        CurrentUser         = $system.CurrentUser
        IsLaptop            = $system.IsLaptop
        IsVpn               = $system.IsVpn
        IsVm                = $system.IsVm
        IsThinClient        = $system.isThinClient
        IsServer            = if($os.Caption -like "*Server*"){1}else{0}
        IsDesktop            = if($os.Caption -notlike "*server*" -and $system.IsLaptop -eq 0 -and $system.isVm -eq 0 -and $system.IsThinClient -eq 0){1}else{0}
        RamInstalledGb      = $system.RamInstalledGb
        RamUpgradableGb     = $memoryArray.RamUpgradableGb
        RamSlotTotal        = $memoryArray.RamSlotTotal
        RamSlotUsed         = (Get-fnPhysicalMemory -computerName $computerName).RamSlotUsed
        Processor           = $processor.Name
        NumberOfCores       = $processor.NumberOfCores
        NumberOfEnabledCore = $processor.NumberOfEnabledCore
        CurrentClockSpeed   = $processor.CurrentClockSpeed
        DiskModel           = $disk.Model
        DiskSizeGb          = $disk.DiskSizeGb
        DiskType            = (Get-fnPhysicalDisk -computerName $computerName).DiskType
        TpmEnabled          = $tpm.TpmEnabled
        TpmVersion          = $tpm.TpmVersion
        MacAddresses        = (Get-fnMacAddress -computerName $computerName).MacAddresses
        LastRebootDate      = $os.LastReboot
        EncryptionLevel     = $os.EncryptionLevel
        OsArchitecture      = $os.OsArchitecture
        NumberOfUsers       = $os.NumberOfUsers
        OsBuildNumber       = $os.BuildNumber
        OsBuildType         = $os.OsBuildType
        OsVersion           = $os.Version
        Caption             = $os.Caption 
        OsCountryCode       = $os.OsCountryCode
        LastSecurityUpdateDate = $hotfix.LastSecurityUpdateDate
        LastSecurityUpdate  = $hotfix.LastSecurityUpdate
        LastPatch           = $hotfix.LastPatch
        LastPatchDate       = $hotfix.LastPatchDate
    }
    
    return $comp
}