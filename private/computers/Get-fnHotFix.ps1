function Get-fnHotFix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $sec = Get-HotFix -ComputerName $computerName | 
                Where-Object {$_.Description -eq "Security Update"} | 
                Sort-Object InstalledOn -Descending | 
                Select-Object -First 1

        $update = Get-HotFix -ComputerName $computerName | 
                    Where-Object {$_.Description -eq "Update"} | 
                    Sort-Object InstalledOn -Descending | 
                    Select-Object -First 1
        
        $patches = [PSCustomObject]@{
            LastSecurityUpdate = $sec.HotFixID
            LastSecurityUpdateDate = $sec.InstalledOn
            LastPatch = $update.HotFixID
            LastPatchDate = $update.InstalledOn
        }

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $patches
}