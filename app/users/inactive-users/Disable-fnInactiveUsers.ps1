function Disable-fnInactiveUsers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$users
    )
    Write-Information "$($MyInvocation.MyCommand.Name):  "

    #try cath when there is possibility of exception
    try {
        foreach($user in $inactiveUsers){
            Write-Verbose "Disable $($user.SamAccountName) - last login: $($user.LastLogonDate), last modified: $($user.Modified), created: $($user.Created)"
            Disable-AdAccount -Identity $user.SamAccountName
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}