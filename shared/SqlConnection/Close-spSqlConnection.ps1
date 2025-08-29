function Close-spSqlConnection {

    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Data.Common.DbConnection]$conn,
        [Parameter()]
        [System.Data.Common.DbCommand]$cmd
    )
    $conn.Dispose()
    $cmd.Dispose()
    $conn.Close()
}