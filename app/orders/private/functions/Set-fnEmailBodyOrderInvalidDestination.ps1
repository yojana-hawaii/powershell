function Set-fnEmailBodyOrderInvalidDestination {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email,
        [parameter()]
        [System.Object]$order
    )
    
    $email.emailBody4["Internal-$($order.type)"] = $order.intDestination
    $email.emailBody4["External-$($order.type)"] = $order.extDestination
    $email.emailBody4["DELETE"] = $order.delDestination
    $email.emailBody4["Internal-Labs"] = "Combined with external labs."
    
    $email.emailBody5 = Join-fnTwoOrderArray -array1 $email.emailBody5 -array2 $order.extSummary -type $order.type -array2_prefix "External"            
    $email.emailBody5 = Join-fnTwoOrderArray -array1 $email.emailBody5 -array2 $order.intSummary -type $order.type -array2_prefix "Internal"      

    $email.emailBody6["$($order.type)"] = $($order.internalList)
}