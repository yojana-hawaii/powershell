function Push-fnInsertAdComputers {
    [CmdletBinding()]
    param (
        [System.Object]$computers
    )
    $total = $computers.count 
    $cnt = 1
    foreach($computer in $computers){
        Write-Information "Inserting $cnt of $total computers, $($computer.sAMAccountName)"
        Invoke-spAdComputer -computer $computer
        $cnt++
    }
}