 function Get-fnEmailConfig_CompExport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = $email.me

    $email.subject = "$($email.compExportSubject)"
    $tempbody = "<p>$($email.compExportBody)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodyhtml + $email.bodysig

}