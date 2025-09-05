function Update-fnInvalidDestination {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email,
        [parameter()]
        [System.Object]$order
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Create new Destination files "
    $order = Remove-fnOrderNotReadyForFollowup -order $order
    $order = Get-fnDeletedOrders -order $order
    $order = Get-fnInternalOrders -order $order
    
    $order = Group-fnOrdersByGroupConfig -order $order
        
    Export-fnGroupedObjectToSeparateCsv -groupObject $order.internaldata -destination $order.intDestination
    Export-fnGroupedObjectToSeparateCsv -groupObject $order.externaldata -destination $order.extDestination

    Set-fnEmailBodyOrderInvalidDestination -email $email -order $order
    
    return $order
}