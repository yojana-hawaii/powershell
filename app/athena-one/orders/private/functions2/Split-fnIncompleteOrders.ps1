function Split-fnIncompleteOrders {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Split orders that dont need follow up."

    #try cath when there is possibility of exception
    try { 
        # separate out delete column
        Split-fnFilterByString -param $param -filterStr "delete"
        # separate out blood draw and social determinant of health column
        Split-fnFilterByString -param $param -filterStr "bloodDraw"
        Split-fnFilterByString -param $param -filterStr "socialDeterminant"
        
        # filter out not due yet:  performDays + default alarm days < select date
        Split-fnFilterByDate -param $param -filterStr "alarm"
        # more than 6 months = ready to delete
        Split-fnFilterByDate -param $param -filterStr "expired"
        # filter out recently action taken: LastUpdate + 14 days < select date
        Split-fnFilterByDate -param $param -filterStr "lastUpdate"

        # more than 3 momths or expiring soon - ?


        $param.splitSuccess = $true
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}