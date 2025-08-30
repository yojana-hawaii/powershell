function Push-fnInsertAdUsers {
    [CmdletBinding()]
    param (
        [System.Object]$users
    )
    $total = $users.count
    $cnt = 1
    foreach($user in $users){
        Write-Information "Inserting $cnt of $total users, $($user.sAMAccountName)"
        # $user
        Invoke-spAdUser -user $user
        $cnt++
    }
}