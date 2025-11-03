 function Get-fnEmailConfig_CompExport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [hashtable]$param
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = $email.helpdesk
    $email.cc = $email.me

    $email.subject = "$($email.compExportSubject)"
    $tempbody = "<p>$($email.compExportBody)</p>"

    $focus = "<p><h3>Area of focus</h3>
            <ul>
                <li>Dell Encryption: $(($param.OldEncryption).Count)</li>
                <li>Windows 10:  $(($param.Windows10).Count)</li>
                <li></li>
            </ul>
            </p>"

    $email.body = $email.bodyintro + $tempbody + $focus + $email.bodyhtml + $email.bodysig

}