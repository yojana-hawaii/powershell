function fnLocal_DiskTyp($pmediaType){
    $disk = ''
    switch ($pmediaType) {
        3 { $disk = 'HDD' }
        4 { $disk = 'SDD' }
        5 { $disk = 'SCM' }
        Default {$disk = $pmediaType}
    }
    return $disk
}
function Get-fnPhysicalDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $disk = Get-CimInstance -Class MSFT_PhysicalDisk -ComputerName $computerName -Namespace root\Microsoft\Windows\Storage | 
                    Select-Object @{
                        label = "DiskType"
                        expression = {fnLocal_DiskTyp($_.MediaType)}
                    }
        $diskObject = [PSCustomObject]@{
            DiskType = $disk.DiskType -join ", "
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $diskObject
}
