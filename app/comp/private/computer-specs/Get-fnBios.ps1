function Get-fnBios {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName    
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $bios = Get-CimInstance -Class Win32_Bios -ComputerName $computerName | 
                    Select-Object SerialNumber,
                    @{
                        label = "BiosVersion"
                        expression = {$_.SMBIOSBIOSVersion}
                    }, @{
                        label="BiosReleaseDate"
                        expression={$_.ReleaseDate}
                    }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $bios
}
