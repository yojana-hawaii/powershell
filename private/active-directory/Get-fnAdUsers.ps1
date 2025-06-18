function Get-fnAdUsers {
    [CmdletBinding()]
    param (
        [parameter()]
        [bool]$enabled = $true,
        [parameter()]
        [string]$identity = 'all'
    )
    Write-Information "$($MyInvocation.MyCommand.Name)"

    $filter = "enabled -eq '$enabled' "

    if($identity -ne 'all'){
        $filter = "Name -eq $identity"
    }

 
    try {
        $users = Get-ADUser  -Filter $filter -Properties * |
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
                            expression={[datetime]::FromFileTime($_.AccoountExpires) }
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
                        PasswordNeverExpires, PasswordExpired, 
                        @{
                            label = "PasswordLastSetDate"
                            expression = {_.PasswordLastSet}

                        },
                        ScriptPath, LogonCount, EmployeeId,
                        @{
                            label="Manager"
                            expression={
                                if($null -ne $_.Manager){ (Get-Aduser -Identity $_.Manager).sAMAccountName} else {"no manager"}
                            }
                        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
    return $users
}