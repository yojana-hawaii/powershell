function Set-fnEmailHtmlCombine {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email
    )

    Write-Information "$($MyInvocation.MyCommand.Name): Set email body to html"

    # send test email to me
    # $email.To = $email.me
    # $email.CC = $email.me
    # $email.From = $email.me

    
    Write-Information "Body 1 : $($email.emailBody1)"
    Write-Information "Body 2 : $($email.emailBody2)"
    Write-Information "Body 3 : $($email.emailBody3)"
    Write-Information "Body 5 : $($email.emailBody4)"
    Write-Information "Body 6 : $($email.emailBody5)"
    Write-Information "Body 7 : $($email.emailBody6)"
    $email.body = "
            $($email.htmlStart)
            $(if($null -ne $email.emailBody1) {$email.emailBody1})
            $(if($null -ne $email.emailBody2) {$email.emailBody2})
            $(if($null -ne $email.emailBody3) {$email.emailBody3})  


            $(if($null -ne $email.emailBody4) {$email.emailBody4})  
            $(if($null -ne $email.emailBody5) {$email.emailBody5})  
            $(if($null -ne $email.emailBody6) {$email.emailBody6})  

            $(if($null -ne $email.emailSig) {"<p style=text-align:left>Thank you,</br>$($email.emailSig) </p>"}) 
      
            
            $($email.htmlEnd)
            "
    
}