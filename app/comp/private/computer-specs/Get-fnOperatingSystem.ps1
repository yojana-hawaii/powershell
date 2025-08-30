function Get-fnOperatingSystem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $os = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $computerName | 
                Select-Object EncryptionLevel,NumberOfUsers, OsArchitecture, BuildNumber, BuildType, Version, Caption,
                @{
                    label = "LastReboot"
                    expression = {$_.LastBootUpTime}
                    
                },
                @{
                    label = "OsCountryCode"
                    expression = {if($_.CountryCode -eq 1){"US"} else {$_.CountryCode}}
                },
                @{
                    label = "OsInstallDate"
                    expression = {$_.InstallDate}
                },
                @{
                    label = "OsLanguage"
                    expression = {if($_.OsLanguage -eq "1033"){"US-English"} else {$_.OsLanguage}}
                }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $os
}
