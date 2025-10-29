function Get-fnEmailConfig_DentalCyrca {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = ($email.dentalTo) -Split ";"
    $email.cc = $email.me

    $email.subject = "$($email.dentalSubject)"
    $tempbody = "<p>$($email.dentalBody)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodyhtml + $email.bodysig
}