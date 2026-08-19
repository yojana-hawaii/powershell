function Invoke-fnSpWorkstationSoftwares_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$softwares
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareName", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareVendor", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareVersion", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareInstallDate", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareInstallLocation", [string]) | Out-Null
    $dataTable.Columns.Add("SoftwareInstallSource", [string]) | Out-Null

    foreach($row in $softwares){
        $dataTable.Rows.Add(
                $row.ComputerName, $row.SoftwareName, $row.SoftwareVendor, $row.SoftwareVersion, $row.SoftwareInstallDate,
                    $row.SoftwareInstallLocation, $row.SoftwareInstallSource
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationSoftwares_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@softwares", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationSoftwares"
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




