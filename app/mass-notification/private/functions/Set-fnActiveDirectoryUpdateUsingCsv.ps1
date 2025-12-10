function Set-fnActiveDirectoryUpdateUsingCsv {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$CsvPath
    )

    $usersWithErrors = @()
    $users = Import-Csv -Path $CsvPath

    foreach($user in $users){
        write-host $user
        $location = $user.location
        $department = $user.department
        $jobtitle = $user.jobtitle

        try {     
            $manager = get-aduser -Filter "EmailAddress -eq '$($user.managerEmail)'"
            $staff = get-aduser -Filter "EmailAddress -eq '$($user.staffEmail)'" -Properties Manager, StreetAddress, Department, Title
                
    
            Write-Verbose "working on $($user.first) $($user.last) with username: $($staff.SamAccountName), manager: $($manager.SamAccountName), location: $location, department: $department, title: $jobtitle "
            Write-Verbose "location: $($staff.StreetAddress), department: $($staff.Department), title: $($staff.Title) "

            # update managr only if different
            if($manager.DistinguishedName  -eq $staff.manager){
                Write-Verbose "Manager is correct: $($staff.manager)"
            } else {
                Write-Verbose "Manager is different - change $($staff.manager) to $manager"
                Set-ADUser -Identity $staff -Manager $manager
            }

            # update location only if differnt
            if($location -eq $staff.StreetAddress){
                Write-Verbose "Location is correct: $($staff.StreetAddress)"
            } else {
                Write-Verbose "Location is different - change $($staff.StreetAddress) to $location"
                Set-ADUser -Identity $staff -StreetAddress $location
            }

            # update department if different
            if($department -eq $staff.Department){
                Write-Verbose "Department is correct: $($staff.Department)"
            } else {
                Write-Verbose "Department is different - change $($staff.Department) to $department"
                Set-ADUser -Identity $staff -Department $department
            }

            # update title if different
            if($jobtitle -eq $staff.title){
                Write-Verbose "Title is correct: $($staff.Title)"
            } else {
                Write-Verbose "Title is different - change $($staff.Title) to $jobtitle"
                Set-ADUser -Identity $staff -Title $jobtitle
            }

        } catch {
            #cannot update manager coz user cannot be found, manager cannot be found, email mismatch etc. 
            Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
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
