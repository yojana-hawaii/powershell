function Get-fnEmailConfig_VendorsAndStudents {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.queenB
    $email.cc = $($email.helpdesk)


    $email.subject = "$($email.vendorstudentsubject)"
    $tempbody = "$($email.vendorstudentbody1) $($email.fullname)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodysig
}