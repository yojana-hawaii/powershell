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

    #region - round one filtering
    # Three filters to get started
    # 1. user has to be enabled
    # 2. do not disable accounts modified within past 2 days - something was modified for a reason
    # 3. logondate from one DC - 14 days
    $inactiveUsers = Get-ADUser -Filter * -Properties * -SearchBase $ou | 
    Where-Object {
        $_.enabled -and # look at only active accounts
        $_.modified -le $lastModifiedDateToKeep -and # if account modifed in last 2 days -> do not disable
        # $_.LastLogonDate -le  $lastLoginDateToKeepActive  #last-logon 14 login
        [DateTime]::FromFileTime($_.LastLogon) -le  $lastLoginDateToKeepActive  #last-logon 14 login
    }  | 
    Select-Object  Name, sAMAccountName, Enabled, Created, Modified, Description , EmailAddress, Company, 
    @{
        label = "Manager"
        expression = {
            if($null -ne $_.Manager){ (Get-ADUser -Identity $_.Manager -Properties EmailAddress).emailAddress} else {""}
        }
    },@{
        label = "Type"
        expression = {if($_.EmailAddress) {$_.EmailAddress} elseif ($_.Company) {$_.Company} else  {$type} }
    }, LastLogonDate,@{
        label="LastLogon"
        expression={ [DateTime]::FromFileTime($_.LastLogon) }
    },@{
        label="LastLogonTimeStamp"
        expression={ [DateTime]::FromFileTime($_.LastLogonTimeStamp) }
    }
    #endregion
    
    #region - Never logged in 
    # new account created with past 30 days but not started yet.
    if($inactiveUsers){
        $inactiveUsers = $inactiveUsers | 
        Where-Object {
            # never login but created within 30 days (new hire account creation)
            -not ((  $null -eq $_.LastLogon -or $_.LastLogon -eq "" -or $_.LastLogon -eq "12/31/1600 2:00:00 PM" ) -and 
                $_.Created -ge $neverLoggedInDateToKeepActive)
        }
    }
    #endregion

    #region - check all DC
    # From the inactive list check, check each domain controller to see if they are logged in 
    # Last logon does not sync right away (takes 10-15 days) between domain controllers
    # okta only login does not seem to be syncing back to AD - vendors possiblly premature disable


    $dcs = (Get-ADDomainController -filter * ).Name

    foreach($user in $inactiveUsers){
        $maxDate = [datetime]"1900-01-01"
        $dcs | ForEach-Object {
            $dcLogon = Get-ADUser -Identity $user.sAMAccountName -Properties * | 
            Select-Object sAMAccountName, LastLogonDate,@{
                    label="LastLogon"
                    expression={ [DateTime]::FromFileTime($_.LastLogon) }
                },@{
                    label="LastLogonTimeStamp"
                    expression={ [DateTime]::FromFileTime($_.LastLogonTimeStamp) }
                }

            if($maxDate -lt $dcLogon.LastLogon){
                $maxDate = $dcLogon.LastLogon
            }
            if($maxDate -lt $dcLogon.LastLogonTimeStamp){
                $maxDate = $dcLogon.LastLogonTimeStamp
            }
            if($maxDate -lt $dcLogon.LastLogonDate){
                $maxDate = $dcLogon.LastLogonDate
            }
        }
        if($maxDate -gt $lastLoginDateToKeepActive){
            # remove from inactive list
            $inactiveUsers = $inactiveUsers | Where-Object { $_ -ne $user}
            continue
        }
    }

    #endregion

    return $inactiveUsers
}