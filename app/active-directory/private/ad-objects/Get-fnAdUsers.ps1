function Get-fnAdUsers {
    [CmdletBinding()]
    param (
        [parameter()]
        [bool]$enabled = $true,
        [parameter()]
        [string]$identity = 'all'
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name) with enabled as $enabled and identity as $identity "

    $filter = "enabled -eq '$enabled' "

    if($identity -ne 'all'){
        $filter = "Name -eq $identity"
    } else {
        $filter = "*"
    }

 
    $properties = @(
                    "CanonicalName", "sAMAccountName","userPrincipalName", "GivenName", "SurName",
                    "DisplayName", "emailAddress", "DistinguishedName", "StreetAddress",
                    "HomePhone", "MobilePhone", "OfficePhone", "Fax",
                    "Company", "Department","Title", "Description",
                    "Enabled", "LastLogonDate", 
                    "AccountExpires", "whenCreated", "whenChanged",
                    "PasswordNeverExpires", "PasswordExpired", "PasswordLastSet",
                    "ScriptPath", "LogonCount", "EmployeeId",
                    "Manager"
                )

    try {
        $users = Get-ADUser  -Properties $properties -Filter $filter | 
                    Select-Object CanonicalName, sAMAccountName,userPrincipalName,
                        @{
                            label = "FirstName"
                            expression = {$_.GivenName}
                        },
                        @{
                            label = "LastName"
                            expression = {$_.SurName}
                        },
                        DisplayName, emailAddress, DistinguishedName, StreetAddress,
                        HomePhone, MobilePhone, OfficePhone, Fax,
                        Company, Department,Title, Description,
                        @{
                            label="AccountExpirationDate"
                            expression={[datetime]::FromFileTime($_.AccountExpires) }
                        },
                        Enabled, LastLogonDate, 
                        @{
                            label = 'CreatedDate'
                            expression = {$_.whenCreated}
                        },
                        @{
                            label = 'ModifiedDate'
                            expression = {$_.whenChanged}
                        },
                        PasswordNeverExpires, PasswordExpired,PasswordLastSet,
                        @{
                            label = "PasswordLastSetDate"
                            expression = {$_.PasswordLastSet}
                        },
                        @{
                            label="Manager"
                            expression={
                                    if($null -ne $_.Manager){ (Get-Aduser -Identity $_.Manager).sAMAccountName} else {""}
                                }
                        },
                    ScriptPath, LogonCount, EmployeeId
        return $users
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
}