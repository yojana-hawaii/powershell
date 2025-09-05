function Update-fnValidSourceAndDestination {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email,
        [parameter()]
        [string]$type
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Do nothing for $type"
    $email.emailBody2 += "$type,"
}