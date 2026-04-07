function Get-fnEmailConfig_IncompleteOrdersDetails {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [PSCustomObject]$providerDetail
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."
    
    $email.Subject = "Incomplete Orders for $($providerDetail.Name)"

    if($null -eq $email.To){
        $email.To = $email.supportStaffFrom
        $email.Cc = $email.supportStaffCC
        $email.Subject = "Incomplete Order - Missing support staff for $($providerDetail.Name)"
    }

    $email.bodyhtml = Get-fnHtmlTable_Provider -providerDetail $providerDetail

    $email.body = $email.bodyintro + $email.bodyhtml + $email.bodysig
    
}