function Set-fnActiveDirectoryManager {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$CsvPath
    )
    $usersWithErrors = @()
    $users = Import-Csv -Path $CsvPath
    foreach($user in $users){
        $managerUsername = $user.managerEmail -replace "@kphc.org", ""
        $staffUsername = $user.staffEmail -replace "@kphc.org", ""

        Write-Verbose "working on $($user.first) $($user.last) with manager $($user.manager) "
        
        try {
            $manager = get-aduser -Identity $managerUsername
            $staff = get-aduser -Identity $staffUsername -Properties manager
            
            #update only if different
            if($manager.DistinguishedName  -eq $staff.manager){
                Write-Verbose "Same as $($staff.manager)"
    
            } else {
                Write-Verbose "Different $($staff.manager)"
                Write-Verbose "New $manager"
                Set-ADUser -Identity $staff -Manager $manager
            }

        } catch {
            #cannot update manager coz user cannot be found, manager cannot be found, email mismatch etc. 
            $usersWithErrors += [PSCustomObject]@{
                First = $user.First
                Last = $user.Last
                Email = if(($user.staffEmail).count -gt 1) {"more than one"} else {$user.staffEmail}
                Manager = $user.manager
            }
        }
        

    }
    return $usersWithErrors
}

