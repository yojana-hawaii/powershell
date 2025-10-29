function  Get-fnEmailConfig_EnableReturningUsers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = "$($email.helpdesk);$($email.hr)" -split ";"

    if($null -ne $email.managerEmail){
        $email.to = $email.managerEmail
    }
    

    $email.subject = "$($email.enableUserSubject)"
    $tempbody = "$($email.enableUserBody1) $($email.fullname)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.enableUserBody2 + $email.bodysig

    $email.managerEmail = $null
    $email.fullname = $null
}