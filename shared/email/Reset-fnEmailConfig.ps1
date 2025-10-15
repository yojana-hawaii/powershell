function Reset-fnEmailConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): reset basic email"

    $email.to = $null
    $email.subject = $null
    $email.body = $null
    $email.cc = $null
    $email.bodyhtml = $null
}