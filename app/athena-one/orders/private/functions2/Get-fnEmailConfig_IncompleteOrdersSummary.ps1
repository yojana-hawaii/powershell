function Get-fnEmailConfig_IncompleteOrdersSummary {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [hashtable]$orderHash
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for order summary email."

    $email.to = $email.orderTo
    $email.cc = $email.orderCC
    $email.subject = $email.orderSubject   

    $email.incompleteOrderStepByStepProcess  = Get-fnStepByStepProcess -email $email -orderHash $orderHash
    $email.bodyhtml = Get-fnHtmlTable_Summary -orderHash $orderHash

    $email.body = $email.bodyintro + $email.bodyhtml + $email.incompleteOrderStepByStepProcess + $email.bodysig    
}