function Set-fnInternalOrders {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param,
        [string]$filterStr
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Identity internal orders for $filterStr"

    #try cath when there is possibility of exception
    try {
        $propertyName = "internal$($filterStr)"
        $internalOrders = (Read-fnCsvDefaultHeader -filename $param.$propertyName).order

        $param.sourceData | 
            Where-Object { $_.OrderName -in $internalOrders} |
            ForEach-Object {
                $_.OrderType = "internal-$($_.OrderType)"
            }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}