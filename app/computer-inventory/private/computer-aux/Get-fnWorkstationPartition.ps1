function Get-fnWorkstationPartition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        Get-CimInstance -class  msft_partition -Namespace root\Microsoft\Windows\Storage -ComputerName $computerName | 
            Select-Object @{
                label = "ComputerName"
                expression = {$computerName}
            }, PartitionNumber, DiskNumber, 
                IsBoot, IsHidden, IsSystem, IsReadOnly, IsOffline, IsActive,
                DriveLetter, 
                @{
                    label = "PartitionSizeGb"
                    expression = {[Math]::Round($_.Size / 1Gb, 2)}
                }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}