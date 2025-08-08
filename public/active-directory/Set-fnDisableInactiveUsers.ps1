set-location "\\fileserver\it\apps\powershell"

function fnLocal_FindInactiveUsers{
    [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$ou,
            [Parameter()]
            [string]$type
        )

    $lastLoginDateToKeepActive = (get-date).AddDays(-$inactiveDays)
    $lastModifiedDateToKeep = (get-date).AddDays(-2)
    $neverLoggedInDateToKeepActive = (get-date).AddDays(-30)

    Write-Verbose "Cutoff dates - Login Date: $lastLoginDateToKeepActive, Modified Date: $lastModifiedDateToKeep, Never Logged in: $neverLoggedInDateToKeepActive"
    $inactiveUsers = Get-ADUser -Filter * -Properties * -SearchBase $ou | 
                        Where-Object {
                                $_.enabled -and # look at only active accounts
                                $_.modified -le $lastModifiedDateToKeep -and # if account modifed in last 2 days -> do not disable
                                $_.LastLogonDate -le  $lastLoginDateToKeepActive  #last-logon 14 login
                            } |
                        Select-Object Name, sAMAccountName, Enabled, LastLogonDate, Created, Modified, Description , EmailAddress,
                        @{
                            label = "Manager"
                            expression = {
                                if($null -ne $_.Manager){ (Get-ADUser -Identity $_.Manager -Properties EmailAddress).emailAddress} else {""}
                            }
                        },
                        @{
                            label = "Type"
                            expression = {if($_.EmailAddress -eq "" -or $null -eq $_.EmailAddress) {$type} else {$_.EmailAddress} }
                        }
    $inactiveUsers = $inactiveUsers | Where-Object {
                                            # never login but created within 30 days (new hire account creation)
                                            (  $null -eq $_.LastLogonDate -or $_.LastLogonDate -eq "" ) -and 
                                                $_.Created -le $neverLoggedInDateToKeepActive
                                            } |
                                    Select-Object Name, sAMAccountName, Enabled, LastLogonDate, Created, Modified, Description , EmailAddress,Manager,Type
    return $inactiveUsers
}
function fnLocal_CreateUserHtmlTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$users
    )

    $users = $users | Select-Object Name, Type,
                @{
                    label = "LastLogin"
                    expression = {if($_.LastLogonDate -eq "" -or $null -eq $_.LastLogonDate) {"Never"} else {($_.LastLogonDate).ToString("MM-dd-yyyy")}}
                }

    $HtmlTable = "<table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Name</b></th>
            <th align=left><b>Last Login</b></th>
            <th align=left><b>Type</b></th>
        </tr>
    "

    foreach($row in $users){
        $email = if ($row.EmailAddress -eq "" -or $null -eq $row.EmailAddress) {$row.EmailAddress} else {$row.Type}

        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td> $($row.Name) </td>
            <td> $($row.LastLogin) </td>
            <td> $email </td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    return $HtmlTable    
}
function fnLocal_BuildEmailBody{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$groupedUsers,
        [parameter()]
        [int]$days = 14
    )
    if($groupedUsers.Name -ne "") {
        $email.To = $groupedUsers.Name
        $email.Cc = ("$($email.helpdesk);$($email.Hr)") -split ";"
        $email.Subject = "$($groupedUsers.Count) user(s) has been disabled."
    } else {
        $email.To = $email.Hr
        $email.Cc = $email.helpdesk
        $email.Subject = "$($groupedUsers.Count) user(s) unknown supervisor has been disabled."
    }

    $userTable  = fnLocal_CreateUserHtmlTable -users $groupedUsers.Group 


    $email.Body = "Hello all, This is an automated email." + 
        "<br><br>The following have not logged into computers system in office or remotely in the past " + 
        $days + 
        " days. Their accounts have been disabled as of now.<br><br>" + 
        "Please notify $($email.helpdesk) whether the user has been " +
        "<br>  a. Terminated: IT team will initiate termination rocess" + 
        "<br>  b. Leave: Please notify $($email.helpdesk) before return to office. It takes more than one hour for account to be ready for use.<br><br>" +
        $userTable +
        "<br><br>Thank you.<br>IT Team"
}
function Set-fnDisableInactiveUsers {
    #region - Import necessary configs and private functions #>
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnOuConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $emailConfig        = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnEmailConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"                        -ErrorAction SilentlyContinue -Recurse)
    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($configHelper + $utility + $emailConfig)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }

    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $config = Get-fnOuConfig 
    $employee_ou = ($config.employee_ou) -replace '"', ""
    $student_ou = ($config.student_ou) -replace '"', ""
    $vendor_ou = ($config.vendor_ou) -replace '"', ""

    $emailConfig =  Get-fnEmailConfig

    $email = @{
        Smtp            = ($emailConfig.smtp) -replace '"',""
        To              = ""
        Cc              = ""
        From            = ($emailConfig.myEmail) -replace '"',""
        Helpdesk        = ($emailConfig.helpdesk) -replace '"',""
        Sig             = ($emailConfig.mySig) -replace '"',""
        Hr              = ($emailConfig.hr) -replace '"', ""
        Subject         = ""
        Body            = ""
    }
    $inactiveDays = 14

    Write-Verbose "GET ALL INACTIVE USERS"
    $inactiveUsers = @()    
    $inactiveUsers += fnLocal_FindInactiveUsers -ou $employee_ou -type "Staff"
    $inactiveUsers += fnLocal_FindInactiveUsers -ou $student_ou -type "Student"
    $inactiveUsers += fnLocal_FindInactiveUsers -ou $vendor_ou -type "Vendor"


    Write-Verbose "DISABLE USERS"
    foreach($user in $inactiveUsers){
        Write-Verbose "Disable $($user.SamAccountName) - last login: $($user.LastLogonDate), last modified: $($user.Modified), created: $($user.Created)"
        Disable-AdAccount -Identity $user.SamAccountName
    }
    write-verbose "GROUP USERS BY MANAGER AND SEND EMAIL"
    $grps = $inactiveUsers | Group-Object Manager
    foreach($grp in $grps){
        fnLocal_BuildEmailBody -groupedUsers $grp -days $inactiveDays     
        Send-MailMessage -smtpserver $email.smtp -from $email.from -to $email.to -cc $email.cc -subject $email.subject -body $email.body -bodyashtml
    }


    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Disable inactive users complete. It took $totalTime" 

}

$Global:today = $null
$today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnDisableInactiveUsers -Verbose -InformationAction continue
Stop-Transcript
