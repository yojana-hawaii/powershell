function Get-fnAdGroups {
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


    Write-Information "$($MyInvocation.MyCommand.Name): get groups changed in last $changeSinceDate"

    try {
        $groups = Get-ADGroup -Filter {whenChanged -gt $changeSinceDate } -Properties * |
            Select-Object CanonicalName, sAMAccountName, Name, mail, DistinguishedName, 
                    Description, 
                    @{
                        label = 'CreatedDate'
                        expression = {$_.whenCreated}
                    },
                    @{
                        label = 'ModifiedDate'
                        expression = {$_.whenChanged}
                    },
                    GroupCategory, GroupScope
        
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
    return $groups

}
