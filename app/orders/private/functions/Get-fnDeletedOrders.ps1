function Get-fnDeletedOrders {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$order    
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Separate deleted documents on $($order.delete[0]) column on '$($order.delete[1])"
    $deleteColumn = ($order.delete[0]).ToString()
    $deleteValue = ($order.delete[1]).ToString()
    $data = $order.externaldata
    $order.deletedata = $data | Where-Object {$_.$deleteColumn -eq $deleteValue}
    $order.externaldata = $data | Where-Object {$_.$deleteColumn -ne $deleteValue}
        
    return $order
}