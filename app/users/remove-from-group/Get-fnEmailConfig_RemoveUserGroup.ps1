function Get-fnEmailConfig_RemoveUserGroup {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [string]$actionsTaken
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = $email.me

    $email.subject = "Users removed from group"
    $tempbody = "<p>$($actionsTaken)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodyhtml + $email.bodysig
}