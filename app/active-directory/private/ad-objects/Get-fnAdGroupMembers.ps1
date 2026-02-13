function Get-fnAdGroupMembers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$deltaChangeHours = 1,

        [Parameter()]
        [switch]$Test
    )

    # 1. Date Logic
    $changeSinceDate = if ($deltaChangeHours -eq 0) { 
        (Get-Date).AddYears(-50) 
    } else { 
        (Get-Date).AddHours(-$deltaChangeHours) 
    }

    Write-Information "$($MyInvocation.MyCommand.Name)"

    try {
        # 2. Find groups modified since the cutoff
        $groups = Get-ADGroup -Filter { whenChanged -gt $changeSinceDate } | Select-Object sAMAccountName, DistinguishedName

        # --- TEST BLOCK ---
        if ($Test) {
            Write-Host "--- TEST MODE: Get-fnAdGroupMembers ---" -ForegroundColor Cyan
            Write-Host "Target Date: $changeSinceDate"
            
            if ($null -eq $groups) {
                Write-Warning "No groups found with 'whenChanged' greater than $changeSinceDate."
                Write-Host "Suggestion: Try setting -deltaChangeHours to 0 to see if any groups are returned."
            } else {
                $groupCount = ($groups | Measure-Object).Count
                Write-Host "Groups Found: $groupCount"
                Write-Host "First 3 Groups to be processed: $(($groups.sAMAccountName | Select-Object -First 3) -join ', ')..."
                
                # Sample the first group to see if it has members
                $sampleMemberCount = (Get-ADGroupMember -Identity $groups[0].DistinguishedName).Count
                Write-Host "Sample Check: Group [$($groups[0].sAMAccountName)] contains $sampleMemberCount members."
            }
            return # Exit function after test results
        }
        # ------------------

        # 3. Main Logic: Collect members (using optimized assignment)
        $groupMembers = foreach ($group in $groups) {
            $grpName = $group.sAMAccountName
            
            # Using Get-ADGroupMember; added -ErrorAction SilentlyContinue 
            # to handle empty groups or deleted objects gracefully.
            Get-ADGroupMember -Identity $group.DistinguishedName -ErrorAction SilentlyContinue | ForEach-Object {
                [PSCustomObject]@{
                    ObjectClass         = $_.objectClass
                    Username            = $_.sAMAccountName
                    GroupSamAccountName = $grpName
                }
            }
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }

    return $groupMembers
}
