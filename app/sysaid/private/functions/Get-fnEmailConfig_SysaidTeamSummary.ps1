function Get-fnEmailConfig_SysaidTeamSummary {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$arr,
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for summary email."
    $email.subject = $email.sysaidsubject
    $email.bodyhtml = Get-fnSysaidSummaryHtmlTable -arr $arr
    $email.body = $email.bodyintro + $email.sysaidbody1 + $email.bodyhtml + $email.sysaidbody2 + $email.sysaidbody3 + $email.bodysig
    $email.to = $email.bossEmail
    $email.cc = $email.helpdesk
}