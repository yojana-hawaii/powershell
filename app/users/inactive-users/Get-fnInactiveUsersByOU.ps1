function Get-fnInactiveUsersByOU {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ou,
        [string]$type
    )

    
    $lastLoginDateToKeepActive = (get-date).AddDays(-$inactiveDays)
    $lastModifiedDateToKeep = (get-date).AddDays(-2)
    $neverLoggedInDateToKeepActive = (get-date).AddDays(-30)


    Write-Verbose "Cutoff dates 
    * Last Login Before: $lastLoginDateToKeepActive
    * Last Modified Before: $lastModifiedDateToKeep
    * New account created but Never Logged in: $neverLoggedInDateToKeepActive"
    $inactiveUsers = Get-ADUser -Filter * -Properties * -SearchBase $ou | 
    Where-Object {
        $_.enabled -and # look at only active accounts
        $_.modified -le $lastModifiedDateToKeep -and # if account modifed in last 2 days -> do not disable
        $_.LastLogonDate -le  $lastLoginDateToKeepActive  #last-logon 14 login
    } | Select-Object Name, sAMAccountName, Enabled, LastLogonDate, Created, Modified, Description , EmailAddress, @{
        label = "Manager"
        expression = {
            if($null -ne $_.Manager){ (Get-ADUser -Identity $_.Manager -Properties EmailAddress).emailAddress} else {""}
        }
    },@{
        label = "Type"
        expression = {if($_.EmailAddress -eq "" -or $null -eq $_.EmailAddress) {$type} else {$_.EmailAddress} }
    }
    
    $inactiveUsers = $inactiveUsers | 
        Where-Object {
            # never login but created within 30 days (new hire account creation)
            -not ((  $null -eq $_.LastLogonDate -or $_.LastLogonDate -eq "" ) -and 
                $_.Created -ge $neverLoggedInDateToKeepActive)
            } |
        Select-Object Name, sAMAccountName, Enabled, LastLogonDate, Created, Modified, Description , EmailAddress,Manager,Type


    return $inactiveUsers
}