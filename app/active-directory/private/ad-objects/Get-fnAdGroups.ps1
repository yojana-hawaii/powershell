function Get-fnAdGroups {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$deltaChangeHours = 1,

        [Parameter()]
        [switch]$Test  # Added a test switch
    )

    # 1. Logic for Date remains the same
    $changeSinceDate = if ($deltaChangeHours -eq 0) { 
        (Get-Date).AddYears(-50) 
    } else { 
        (Get-Date).AddHours(-$deltaChangeHours) 
    }

    if ($Test) {
        Write-Host "--- TEST MODE ENABLED ---" -ForegroundColor Cyan
        Write-Host "Target Date: $changeSinceDate"
        Write-Host "Filter String: { whenChanged -gt `$changeSinceDate }"
        
        # Quick check: How many total groups exist vs how many match the filter?
        try {
            $totalCount = (Get-ADGroup -Filter *).Count
            $matchCount = (Get-ADGroup -Filter { whenChanged -gt $changeSinceDate }).Count
            
            Write-Host "Total Groups in AD: $totalCount"
            Write-Host "Groups matching filter: $matchCount"
            
            if ($matchCount -eq 0) {
                Write-Warning "No groups found. Check if 'whenChanged' is being updated in your environment."
            }
        } catch {
            Write-Error "Test failed: Check AD Module connectivity."
        }
        return # Exit early in test mode
    }

    # --- Normal Execution Below ---
    Write-Information "$($MyInvocation.MyCommand.Name): Searching..."

    try {
        $props = @('CanonicalName', 'sAMAccountName', 'Name', 'mail', 
                   'DistinguishedName', 'Description', 'whenCreated', 
                   'whenChanged', 'GroupCategory', 'GroupScope')

        return Get-ADGroup -Filter { whenChanged -gt $changeSinceDate } -Properties $props | 
            Select-Object CanonicalName, sAMAccountName, Name, mail, DistinguishedName, Description, 
                @{Name = 'CreatedDate'; Expression = { $_.whenCreated }},
                @{Name = 'ModifiedDate'; Expression = { $_.whenChanged }},
                GroupCategory, GroupScope
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
}
