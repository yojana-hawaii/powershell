function Get-fnDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $disk = Get-WmiObject -Class Win32_DiskDrive -ComputerName $computerName | 
                    Select-Object Model,
                    @{
                        label = "DiskSizeGb"
                        expression = {[Math]::Round($_.Size / 1Gb, 2)}
                    }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $disk
}