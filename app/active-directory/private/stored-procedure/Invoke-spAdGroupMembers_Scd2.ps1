function Invoke-spAdGroupMembers_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$groupMembers
    )
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("GroupSamAccountName", [string]) | Out-Null
    $dataTable.Columns.Add("Username", [string]) | Out-Null
    $dataTable.Columns.Add("ObjectClass", [string]) | Out-Null


    foreach($row in $groupMembers){
        $dataTable.Rows.Add(
                $row.GroupSamAccountName,$row.Username,$row.ObjectClass
            )
    }
    
    $StoredProcedure = 'dbo.spAdGroupMembers_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@groupmembers", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpAdGroupMembers"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import AD group-members to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}