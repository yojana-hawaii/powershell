function Group-fnOrdersByGroupConfig {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$order
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Group internal, external and delete data for $($order.type)"
    $order.extSummary     = $order.externaldata | Group-Object -Property $order.summaryGroup | Select-Object Name, Count
    $order.intSummary     = $order.internaldata | Group-Object -Property $order.summaryGroup | Select-Object Name, Count

    $order.deletedata     = $order.deletedata  
    $order.internaldata   = $order.internaldata | Group-Object -Property $order.internalgroup
    $order.externaldata   = $order.externaldata | Group-Object -Property $order.externalgroup

    return $order
}