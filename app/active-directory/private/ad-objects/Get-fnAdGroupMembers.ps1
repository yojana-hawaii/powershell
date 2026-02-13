function Get-fnAdGroupMembers {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Hours to look back. Use 0 for all time (50 years).")]
        [int]$deltaChangeHours = 1
    )

    # Determine the cutoff date
    $changeSinceDate = if ($deltaChangeHours -eq 0) { 
        (Get-Date).AddYears(-50) 
    } else { 
        (Get-Date).AddHours(-$deltaChangeHours) 
    }

    Write-Information "Executing: $($MyInvocation.MyCommand.Name)"

    try {
        # Get groups modified since the cutoff
        $groups = Get-ADGroup -Filter {whenChanged -gt $changeSinceDate}

        # Directly assign the loop output to the variable (Avoids +=)
        $groupMembers = foreach ($group in $groups) {
            Write-Verbose "Processing Group: $($group.Name)"
            
            # Get members and transform into objects immediately
            Get-ADGroupMember -Identity $group.DistinguishedName | ForEach-Object {
                [PSCustomObject]@{
                    ObjectClass         = $_.objectClass
                    Username            = $_.sAMAccountName
                    GroupSamAccountName = $group.sAMAccountName
                }
            }
        }
        
        return $groupMembers
    }
    catch {
        Write-Warning "Error in $($MyInvocation.MyCommand.Name): $($_.Exception.Message)"
    }
}