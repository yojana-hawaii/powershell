function Invoke-fnSpWorkstationUserLoggedIn_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$loggedInUsers
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("UserLoggedIn", [string]) | Out-Null
    $dataTable.Columns.Add("UserLastLoggedInDate", [string]) | Out-Null

    foreach($row in $loggedInUsers){
        $dataTable.Rows.Add(
                $row.ComputerName, $row.UserLoggedIn, $row.UserLastLoggedInDate
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationUserLoggedIn_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@userloggedin", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationUserLoggedIn"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import users logged in to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}




