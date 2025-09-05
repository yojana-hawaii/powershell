function Set-fnEmailBodyNull {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email
    )
    $email.emailBody1      = $null
    $email.emailBody1a     = $null
    $email.emailBody2      = $null
    $email.emailBody2a     = $null
    $email.emailBody3      = $null
    $email.emailBody3a     = $null
    $email.emailBody4      = $null      
    $email.emailBody4a     = $null      
    $email.emailBody5      = $null    
    $email.emailBody5a     = $null    
    $email.emailBody6      = $null
    $email.emailBody6a     = $null
}