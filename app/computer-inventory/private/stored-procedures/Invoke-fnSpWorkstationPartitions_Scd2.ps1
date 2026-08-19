function Invoke-fnSpWorkstationPartitions_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$partitions
    )
    
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("PartitionNumber", [string]) | Out-Null
    $dataTable.Columns.Add("DiskNumber", [string]) | Out-Null
    $dataTable.Columns.Add("IsBoot", [string]) | Out-Null
    $dataTable.Columns.Add("IsHidden", [string]) | Out-Null
    $dataTable.Columns.Add("IsSystem", [string]) | Out-Null
    $dataTable.Columns.Add("IsReadOnly", [string]) | Out-Null
    $dataTable.Columns.Add("IsOffline", [string]) | Out-Null
    $dataTable.Columns.Add("IsActive", [string]) | Out-Null
    $dataTable.Columns.Add("DriveLetter", [string]) | Out-Null
    $dataTable.Columns.Add("PartitionSizeGb", [string]) | Out-Null

    foreach($row in $partitions){
        $dataTable.Rows.Add(
                $row.ComputerName,$row.PartitionNumber,$row.DiskNumber,$row.IsBoot,
                $row.IsHidden,$row.IsSystem,$row.IsReadOnly,$row.IsOffline,$row.IsActive,
                $row.DriveLetter,$row.PartitionSizeGb
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationPartitions_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@partitions", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationPartitions"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import partition to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}