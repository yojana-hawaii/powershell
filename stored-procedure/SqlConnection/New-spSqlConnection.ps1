

function New-spSqlConnection {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$StoredProcedureName
    )
    $config = Get-fnConfig
    $connectionString="Server=$($config.sqlserver);Integrated Security=True;Initial Catalog=$($config.database);"
    # Write-Host $connectionString

    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connectionString
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandType = 'StoredProcedure'
    $cmd.CommandText = $StoredProcedureName
    return ($conn,$cmd)
}