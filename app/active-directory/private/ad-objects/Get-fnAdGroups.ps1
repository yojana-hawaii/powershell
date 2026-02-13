function Get-fnAdGroups {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$deltaChangeHours = 1
    )

    # 1. Determine the cutoff date
    $changeSinceDate = if ($deltaChangeHours -eq 0) { 
        (Get-Date).AddYears(-50) 
    } else { 
        (Get-Date).AddHours(-$deltaChangeHours) 
    }

    Write-Information "$($MyInvocation.MyCommand.Name): Searching for groups changed since $changeSinceDate"

    try {
        # 2. Performance Tip: Avoid -Properties *. 
        # Only request the specific properties you need to reduce network load.
        $props = @('CanonicalName', 'sAMAccountName', 'Name', 'mail', 
                   'DistinguishedName', 'Description', 'whenCreated', 
                   'whenChanged', 'GroupCategory', 'GroupScope')

        # 3. Use the variable directly in the Filter script block
        $groups = Get-ADGroup -Filter { whenChanged -gt $changeSinceDate } -Properties $props | 
            Select-Object CanonicalName, sAMAccountName, Name, mail, DistinguishedName, Description, 
                @{Name = 'CreatedDate'; Expression = { $_.whenCreated }},
                @{Name = 'ModifiedDate'; Expression = { $_.whenChanged }},
                GroupCategory, GroupScope
        
        return $groups
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
}
