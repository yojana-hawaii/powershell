function Invoke-fnSpWorkstationPrinters_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$printers
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterName", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterShared", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterShareName", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterDriverName", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterDriverVersion", [string]) | Out-Null
    $dataTable.Columns.Add("PrinterIP", [string]) | Out-Null

    foreach($row in $printers){
        $dataTable.Rows.Add(
                $row.ComputerName, $row.PrinterName, $row.PrinterShared, $row.PrinterShareName, $row.PrinterDriverName,
                    $row.PrinterDriverVersion, $row.PrinterIP
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationPrinters_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@printers", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationPrinters"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import printer to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}