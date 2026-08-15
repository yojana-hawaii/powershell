function Invoke-fnSpWorkstationServices_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$currentServices,
        [Parameter(Mandatory)]
        [string]$computerName
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceName", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceDisplayName", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceState", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceStartMode", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceAcceptPause", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceAcceptStop", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceDelayedAutoStart", [string]) | Out-Null
    $dataTable.Columns.Add("ServiceStartName", [string]) | Out-Null

    foreach($row in $currentServices){
        $dataTable.Rows.Add(
                $computerName, $row.Name, $row.DisplayName, $row.State, $row.StartMode,
                    $row.AcceptPause, $row.AcceptStop, $row.DelayedAutoStart, $row.StartName
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationServicesMergeScd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@services", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationServices"
    $param.Value = $dataTable

    try{

        Write-Information "Import to sql affected $return row(s)"
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}