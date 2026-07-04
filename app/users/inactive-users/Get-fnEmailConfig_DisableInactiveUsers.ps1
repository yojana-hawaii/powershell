function Get-fnEmailConfig_DisableInactiveUsers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [PSCustomObject]$groupedUsers
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = $email.helpdesk
    $email.Subject = "$($groupedUsers.Count) user(s) with unknown (to IT) supervisor has been disabled."

    if($groupedUsers.Name -ne "") {
        $email.To = $groupedUsers.Name
        $email.Cc = ("$($email.helpdesk);$($email.Hr)") -split ";"
        $email.Subject = "$($groupedUsers.Count) user(s) has been disabled."
    }

    $tempbody = "<p>$($email.compExportBody)</p>"

    $email.bodyhtml = Get-fnEmailConfig_DisableInactiveUsers_HtmlTable -users $groupedUsers.Group 


    $tempbody = 
        "<p>The following users have not logged into computers system in office or remotely in the past " + 
        $inactiveDays + " days. Their accounts have been disabled as of now.<br /><br />" + 
        "Please notify $($email.helpdesk) whether the user has been " +
        "<ul><li>Terminated: Notify IT to initiate termination process</li>" + 
        "<li>Leave: Notify IT before return to office. It may take over an one hour for account to be ready for use.</li></ul></p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodyhtml + $email.bodysig
}