function Get-fnHotFix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $hotfix = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $computerName | Select-Object Description, InstalledOn, HotFixID

        $security = $hotfix | Where-Object {$_.Description -eq "Security Update"} |
                        Sort-Object InstalledOn -Descending |
                        Select-Object -First 1

        $regular = $hotfix | Where-Object {$_.Description -eq "Update"} |
                        Sort-Object InstalledOn -Descending | 
                        Select-Object -First 1

        $patches = [PSCustomObject]@{
            LastSecurityUpdate = $security.HotFixID
            LastSecurityUpdateDate = $security.InstalledOn
            LastPatch = $regular.HotFixID
            LastPatchDate = $regular.InstalledOn
        }

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $patches
}