
function Convert-fnLastnameCommaFirstnameToEmailMapping{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$lastCommaFirstName = $null,
        [Parameter()]
        [bool]$isOrg2
    )
    
    if ($isOrg2){
        Write-Verbose "Different validation for second organization"
        $org2email = Convert-fnOrg2ConvertToEmail -lastCommaFirstName $lastCommaFirstName
        return $org2email
    }


    if ($lastCommaFirstName -match "\s\w\.$") {
        Write-Verbose "Removing middle initial from $lastCommaFirstName"
        $lastCommaFirstName = $lastCommaFirstName.Substring(0, $lastCommaFirstName.Length - 3) 
    }
    



    $name = $lastCommaFirstName -split ","
    $last   = $name[0].Trim()
    $first  = $name[1].Trim()
    $username = $first.Substring(0,1) + $last
    
    Write-Verbose "Identified username $username"
    
    try {
        $user = Get-ADUser -Filter '(GivenName -eq $first -and sn -eq $last) -or samAccountName -eq $username'  -Properties mail
        $email = $user.mail
        if($email.count -gt 1){
            $user = Get-ADUser -Filter '(GivenName -eq $first -and sn -eq $last) '  -Properties mail
            $email = $user.mail
        }
    } catch {
        Write-Warning "Name to active directory $lastCommaFirstName failed"
        $email = "Not-Found"
    }
    return $email
}