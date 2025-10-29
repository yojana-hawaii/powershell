function Get-fnEmailConfig_DisableTerminated {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = "$($email.helpdesk);$($email.hr)" -split ";"

    if($null -ne $email.managerEmail){
        $email.To = $email.managerEmail
    }

    $email.subject = "$($email.terminatedUserSubject)"
    $tempbody = "<p>$($email.terminatedUserBody1) $($email.fullname)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.terminatedUserBody2  + $email.terminatedUserBody3 + $email.bodysig
}