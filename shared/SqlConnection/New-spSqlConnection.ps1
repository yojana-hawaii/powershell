

function New-spSqlConnection {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$StoredProcedureName,
        [Parameter()]
        [string]$database="default",
        [Parameter()]
        [string]$sqlServer="default"
    )
    $config = Get-fnConfig
    if($database -eq "default"){$database = $config.database}
    if($sqlServer -eq "default"){$sqlServer = $config.sqlserver}

    $connectionString="Server=$sqlServer;Integrated Security=True;Initial Catalog=$database;"
    # Write-Host $connectionString

    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connectionString
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $cmd.CommandText = $StoredProcedureName
    $cmd.CommandTimeout = 300
    return ($conn,$cmd)
}