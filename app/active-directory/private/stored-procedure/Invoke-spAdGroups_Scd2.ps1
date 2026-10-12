function Invoke-spAdGroups_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$groups
    )
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("CanonicalName", [string]) | Out-Null
    $dataTable.Columns.Add("sAMAccountName", [string]) | Out-Null
    $dataTable.Columns.Add("Name", [string]) | Out-Null
    $dataTable.Columns.Add("Mail", [string]) | Out-Null
    $dataTable.Columns.Add("DistinguishedName", [string]) | Out-Null
    $dataTable.Columns.Add("Description", [string]) | Out-Null
    $dataTable.Columns.Add("GroupCategory", [string]) | Out-Null
    $dataTable.Columns.Add("GroupScope", [string]) | Out-Null
    $dataTable.Columns.Add("CreatedDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("ModifiedDate", [System.DateTime]) | Out-Null

    foreach($row in $groups){
        $dataTable.Rows.Add(
                $row.CanonicalName,$row.sAMAccountName,$row.Name,$row.Mail,
                $row.DistinguishedName,$row.Description,
                $row.GroupCategory,$row.GroupScope,
                $row.CreatedDate, $row.ModifiedDate
            )
    }
    
    $StoredProcedure = 'dbo.spAdGroups_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@groups", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpAdGroups"
    $param.Value = $dataTable

    try{
        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data
        Write-Verbose "Import AD groups to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}