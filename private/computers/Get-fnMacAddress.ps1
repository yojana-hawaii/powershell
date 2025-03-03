function Get-fnMacAddress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $mac = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $computerName |
                    Where-Object {($null -ne $_.macaddress) -and ($null -ne $_.Speed) } |
                    Select-Object macaddress
        $macAddresses = [PSCustomObject]@{
            MacAddresses = $mac.macaddress -join ", "
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $macAddresses
}