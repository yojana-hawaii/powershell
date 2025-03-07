function Get-fnSoftwareFromRegistry {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Get software information from $($computerName)"

    $softwareObject = @()
    try {
        $service = Start-fnRemoteRegistryService -ComputerName $computerName

        if($service.Status -eq "Running"){

            $regLocation = "Software\Microsoft\Windows\CurrentVersion\Uninstall\", 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'

            $regType = [Microsoft.Win32.RegistryHive]::LocalMachine
            $regBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($regType ,$ComputerName)
            
            foreach ($loc in $regLocation){
                if($regBase){
                    $CurrentRegKey  = $regBase.OpenSubKey($loc )
                    $ProgramKey = $CurrentRegKey.GetSubKeyNames() 

                    foreach($key in $ProgramKey){
                        $programs = $regBase.OpenSubKey($loc+$key )
                        
                        $SoftwareName = $programs.GetValue('DisplayName')
                        $softwareVersion = $programs.GetValue('DisplayVersion')
                        $SoftwareVendor = $programs.GetValue('Publisher')
                        $SoftwareInstallDate = $programs.GetValue('InstallDate')
                        $SoftwareInstallLocation = $programs.GetValue('InstallLocation')
                        $SoftwareInstallSource = $programs.GetValue('InstallSource')
                        
                        $softwareObject += [PSCustomObject]@{
                            ComputerName = $ComputerName
                            SoftwareName = $SoftwareName 
                            SoftwareVersion = $softwareVersion
                            SoftwareVendor = $SoftwareVendor
                            SoftwareInstallDate = $SoftwareInstallDate
                            SoftwareInstallLocation = $SoftwareInstallLocation
                            SoftwareInstallSource = $SoftwareInstallSource
                            
                        }

                    }
                }
            }
        }
        $softwareObject = $softwareObject | Where-Object {$null -ne $_.SoftwareName}
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    } 
    finally {
        Write-Information "$($MyInvocation.MyCommand.Name): Final Remote Registry Status $($finalServiceStatus.Status)"
    }
    return $softwareObject
}