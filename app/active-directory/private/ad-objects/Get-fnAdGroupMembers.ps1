function Get-fnAdGroupMembers {
    [CmdletBinding()]
    param (
        [parameter()]
        [int]$deltaChangeHours = 1
    )

    if($deltaChangeHours -eq 0){
        $changeSinceDate = (Get-Date).AddYears(-50)
    } else {
        $changeSinceDate = (Get-Date).AddHours( -$deltaChangeHours)
    }

    Write-Information "$($MyInvocation.MyCommand.Name)"

    try {
        $groups = Get-ADGroup -Filter {whenChanged -gt $changeSinceDate } | Select-Object sAMAccountName

        $groupMembers = @()
        foreach($group in $groups){
            $grp = $group.sAMAccountName.ToString()

            Write-Host $grp
            $groupMembers += Get-ADGroupMember -Identity $grp | Select-Object ObjectClass,
                                @{
                                    label = "Username"
                                    expression = {$_.sAMAccountName}
                                },
                                @{
                                    label = "GroupSamAccountName"
                                    expression = {$grp}
                                }

        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
    return $groupMembers
}

