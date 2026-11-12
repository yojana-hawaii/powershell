function Get-fnEmployeeDetailsFromAD {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$lastCommaFirstName
    )

    $removeOkina = $lastCommaFirstName.Trim().Replace("'","")
    $emp = $removeOkina -split ","
    
    # for now lastname is lastname
    $empLast = $emp[0]

    # first name options 
    # 1. full first name 
    $first0 = $emp[1]
    $tmp = $emp[1].Trim() -split " "
    # 2. just the the first word of the first name
    $first1 = $tmp[0]
    # 3. first two words of the first name
    $first2 = ""
    if($tmp[1]) {
        $first2 = $tmp[0] + " " + $tmp[1]
    } else {
        $first2 = $tmp[0]
    }

    # first initial + lastname
    $username = ($first1.Substring(0,1)+$empLast).Replace(" ","")

    $user = Get-ADUser -Filter "(GivenName -eq '$first0' -and Surname -eq '$empLast') 
                                -or (GivenName -eq '$first1' -and Surname -eq '$empLast') 
                                -or (GivenName -eq '$first2' -and Surname -eq '$empLast') 
                                -or samAccountName -eq '$username'"  `
                        -Properties mail, manager |
        Select-Object GivenName, Surname, samAccountName, mail, Manager

    # if more than one user found > first initial last name > username collision
    if($user.count -gt 1){
        $user = Get-ADUser -Filter "(GivenName -eq '$first0' -and Surname -eq '$empLast')"  `
                        -Properties mail, manager |
        Select-Object GivenName, Surname, samAccountName, mail, Manager
    }
    return $user
}