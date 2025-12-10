function Get-fnEmployeeDetailsFromAD {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$lastCommaFirstName
    )

    $emp = $lastCommaFirstName -split ","
    $fullFirst = $emp[1].Trim().Replace("'","")
    $tmp = $emp[1].Trim() -split " "
    $empFirst = $tmp[0].Trim().Replace("'","")
    # $empMiddle = if($tmp[1]){$tmp[1].Trim()[0]} else {""}
    $empLast = $emp[0].Trim().Replace("'","")

    # first initial + lastname
    $username = ($empFirst.Substring(0,1)+$empLast).Replace(" ","")

    $user = Get-ADUser -Filter "(GivenName -eq '$fullFirst' -and Surname -eq '$empLast') 
                                -or (GivenName -eq '$empFirst' -and Surname -eq '$empLast') 
                                -or samAccountName -eq '$username'"  `
                        -Properties mail, manager |
        Select-Object GivenName, Surname, samAccountName, mail, Manager

    # if more than one user found > first initial last name > username collision
    if($user.count -gt 1){
        $user = Get-ADUser -Filter "(GivenName -eq '$fullFirst' -and Surname -eq '$empLast')"  `
                        -Properties mail, manager |
        Select-Object GivenName, Surname, samAccountName, mail, Manager
    }
    return $user
}