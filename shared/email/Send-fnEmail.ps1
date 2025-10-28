function Send-fnEmail {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): sending email."

    try{
        Write-Host "From: $($email.From) To: $($email.To) Cc: $($email.Cc) Subject: $($email.Subject)"
        # $email.to = $email.me
        # $email.cc = $email.me
        Send-MailMessage -From $email.from -To $email.to -Cc $email.cc -Subject $email.Subject -Body $email.Body -SmtpServer $email.smtp -BodyAsHtml
        Reset-fnEmailConfig -email $email
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

}