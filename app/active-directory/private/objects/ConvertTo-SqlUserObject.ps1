function ConvertTo-SqlUserObject {
    param ($AdUser)

    # Handle AccountExpires (AD's "Never" value is MaxInt64)
    $expDate = $null
    if ($AdUser.accountExpires -gt 0 -and $AdUser.accountExpires -ne 9223372036854775807) {
        $expDate = [datetime]::FromFileTime($AdUser.accountExpires)
    }

    # Resolve Manager DN to sAMAccountName (Optional: requires a quick lookup if not pre-cached)
    $managerName = $null
    if ($AdUser.Manager) {
        # Using Regex to pull the CN out of the DN is faster than a second AD call
        if ($AdUser.Manager -match "CN=(?<name>[^,]+)") {
            $managerName = $Matches['name']
        }
    }

    [PSCustomObject]@{
        sAMAccountName         = $AdUser.sAMAccountName
        UserPrincipalName      = $AdUser.userPrincipalName
        FirstName              = $AdUser.GivenName
        LastName               = $AdUser.Surname
        DisplayName            = $AdUser.DisplayName
        EmailAddress           = $AdUser.mail
        DistinguishedName      = $AdUser.DistinguishedName
        Department             = $AdUser.Department
        Title                  = $AdUser.Title
        Enabled                = [int]$AdUser.Enabled
        CreatedDate            = $AdUser.whenCreated
        ModifiedDate           = $AdUser.whenChanged
        LastLogonDate          = $AdUser.lastLogonDate
        PasswordLastSetDate    = $AdUser.PasswordLastSet
        AccountExpirationDate  = $expDate
        Manager                = $managerName
        EmployeeId             = $AdUser.EmployeeId
    }
}
