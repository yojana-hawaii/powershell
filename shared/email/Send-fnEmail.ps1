function Send-fnEmail {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): sending email."

    try{
        # $email.to = $email.me
        # $email.cc = $email.me
        Send-MailMessage -From $email.from -To $email.to -Cc $email.cc -Subject $email.Subject -Body $email.Body -SmtpServer $email.smtp -BodyAsHtml
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

}