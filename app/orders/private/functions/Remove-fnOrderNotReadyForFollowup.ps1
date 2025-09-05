function Remove-fnOrderNotReadyForFollowup {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$order
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Remove file that are not due for follow up."
    $filterColumn=($order.alarm[0]).ToString()
    $filterValue=$order.alarm[1]
    $excludeColumn1=($order.exclude[0]).ToString()
    $excludeValue1=($order.exclude[1]).ToString()
    $excludeColumn2=($order.exclude[2]).ToString()
    $excludeValue2=($order.exclude[3]).ToString()
    
   <# 
    1. read file
    2. remove data not ready for alarm
    3. remove data with additional exceptions
   #>
    $data = Read-fnCsvDefaultHeader -filename $order.source
    Write-Information "$($MyInvocation.MyCommand.Name): Removing closed orders"
    $data = $data | Where-Object {$_.currentStatus -ne "closed" }
    Write-Information "$($MyInvocation.MyCommand.Name): Removing orders from past $filterValue days"
    $data = $data | Where-Object {$null -ne $_.$filterColumn -and $_.$filterColumn -ne "" ` -and (New-TimeSpan -Start $_.$filterColumn -End $today  ).Days -gt $filterValue }

    Write-Information "$($MyInvocation.MyCommand.Name): Removing orders in $excludeValue1 $excludeColumn1 from past $excludeValue2 $excludeColumn2 days"
    $data = $data | Where-Object { -not ($_.$excludeColumn1 -eq $excludeValue1  ` -and  (New-TimeSpan -Start $_.$excludeColumn2 -End $today  ).Days -le $excludeValue2 )}

    Write-Information "$($MyInvocation.MyCommand.Name): $($data.count) $($order.type) orders need to be closed"

    $order.externaldata = $data 
    return $order
}