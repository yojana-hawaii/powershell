function Invoke-fnGetBcbsApprovedStructuredData_UnpivotRownumberPivot {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$row
    )
    
    $StoredProcedure = 'dbo.spGetBcbsApprovedStructuredData_UnpivotRownumberPivot'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get data structured in bsbc requirement"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mrn", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit1", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit2", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit3", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit4", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit5", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit6", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit7", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit8", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit9", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit10", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@visit11", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $row.MRN
        $cmd.Parameters[1].Value = $row.'Dates Well-Child Care (0-30 mos) 7d'
        $cmd.Parameters[2].Value = $row.'Dates Well-Child Care (0-30 mos) 1m'
        $cmd.Parameters[3].Value = $row.'Dates Well-Child Care (0-30 mos) 2m'
        $cmd.Parameters[4].Value = $row.'Dates Well-Child Care (0-30 mos) 4m'
        $cmd.Parameters[5].Value = $row.'Dates Well-Child Care (0-30 mos) 6m'
        $cmd.Parameters[6].Value = $row.'Dates Well-Child Care (0-30 mos) 9m'
        $cmd.Parameters[7].Value = $row.'Dates Well-Child Care (0-30 mos) 12m'
        $cmd.Parameters[8].Value = $row.'Dates Well-Child Care (0-30 mos) 15m'
        $cmd.Parameters[9].Value = $row.'Dates Well-Child Care (0-30 mos) 18m'
        $cmd.Parameters[10].Value = $row.'Dates Well-Child Care (0-30 mos) 24m'
        $cmd.Parameters[11].Value = $row.'Dates Well-Child Care (0-30 mos) 30m'

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($workstation.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}