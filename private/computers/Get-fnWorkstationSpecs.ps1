function Get-fnWorkstationSpecs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    $comp = [PSCustomObject]@{
        Name                = $computerName
        SerialNumber        = (Get-fnBios -computerName $computerName).SerialNumber
        BiosVersion         = (Get-fnBios -computerName $computerName).BiosVersion
        BiosReleaseDate     = (Get-fnBios -computerName $computerName).BiosReleaseDate
        Manufacturer        = (Get-fnComputerSystem -computerName $computerName).Manufacturer
        Model               = (Get-fnComputerSystem -computerName $computerName).Model
        WakeUpType          = (Get-fnComputerSystem -computerName $computerName).WakeUpType
        CurrentUser         = (Get-fnComputerSystem -computerName $computerName).CurrentUser
        RamInstalledGb      = (Get-fnComputerSystem -computerName $computerName).RamInstalledGb
        RamUpgradableGb     = (Get-fnPhysicalMemoryArray -computerName $computerName).RamUpgradableGb
        RamSlotTotal        = (Get-fnPhysicalMemoryArray -computerName $computerName).RamSlotTotal
        RamSlotUsed         = (Get-fnPhysicalMemory -computerName $computerName).RamSlotUsed
        Processor           = (Get-fnProcessor -computerName $computerName).Name
        NumberOfCores       = (Get-fnProcessor -computerName $computerName).NumberOfCores
        NumberOfEnabledCore = (Get-fnProcessor -computerName $computerName).NumberOfEnabledCore
        CurrentClockSpeed   = (Get-fnProcessor -computerName $computerName).CurrentClockSpeed
        DiskModel           = (Get-fnDisk -computerName $computerName).Model
        DiskSizeGb          = (Get-fnDisk -computerName $computerName).DiskSizeGb
        DiskType            = (Get-fnPhysicalDisk -computerName $computerName).DiskType
        TpmEnabled          = (Get-fnTpm -computerName $computerName).TpmEnabled
        TpmVersion          = (Get-fnTpm -computerName $computerName).TpmVersion
        MacAddresses        = (Get-fnMacAddress -computerName $computerName).MacAddresses
        LastReboot          = (Get-fnOperatingSystem -computerName $computerName).LastReboot
        EncryptionLevel     = (Get-fnOperatingSystem -computerName $computerName).EncryptionLevel
        OsArchitecture      = (Get-fnOperatingSystem -computerName $computerName).OsArchitecture
        NumberOfUsers       = (Get-fnOperatingSystem -computerName $computerName).NumberOfUsers
        OsBuildNumber       = (Get-fnOperatingSystem -computerName $computerName).BuildNumber
        OsBuildType         = (Get-fnOperatingSystem -computerName $computerName).Version
        OsVersion           = (Get-fnOperatingSystem -computerName $computerName).Caption 
        OsCountryCode       = (Get-fnOperatingSystem -computerName $computerName).OsCountryCode
        LastSecurityUpdateDate = (Get-fnHotFix -computerName $computerName).LastSecurityUpdateDate
        LastSecurityUpdate  = (Get-fnHotFix -computerName $computerName).LastSecurityUpdate
        LastPatch           = (Get-fnHotFix -computerName $computerName).LastPatch
        LastPatchDate       = (Get-fnHotFix -computerName $computerName).LastPatchDate
    }
    
    return $comp
}
