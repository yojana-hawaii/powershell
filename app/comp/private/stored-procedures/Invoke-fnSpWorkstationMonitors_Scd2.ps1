function Invoke-fnSpWorkstationMonitors_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$monitors
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("MonitorManufacturer", [string]) | Out-Null
    $dataTable.Columns.Add("MonitorName", [string]) | Out-Null
    $dataTable.Columns.Add("MonitorSerial", [string]) | Out-Null
    $dataTable.Columns.Add("MonitorYear", [string]) | Out-Null
    $dataTable.Columns.Add("MonitorCaption", [string]) | Out-Null
    $dataTable.Columns.Add("", [string]) | Out-Null

    foreach($row in $monitors){
        $dataTable.Rows.Add(
                $row.ComputerName, $row.MonitorManufacturer, $row.MonitorName, $row.MonitorSerial, $row.MonitorYear,
                    $row.MonitorCaption, $row.MonitorResolution
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationMonitors_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@monitors", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationMonitors"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import monitors to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}




