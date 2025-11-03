function Get-fnEmailConfig_IncompleteOrdersDetails {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [hastable]$orderHash
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."


    $email.From = $email.supportStaffFrom
    $email.to = ""
    $email.cc = $email.supportStaffCC
    $email.subject = "Incomplete Orders for $()"

    $email.to = $email.me
    $email.cc = $email.me

    $tempbody = "<p>$($actionsTaken)</p>"

    $email.body = $email.bodyintro + $tempbody + $email.bodyhtml + $email.bodysig
        $orderHash.provDetail

}