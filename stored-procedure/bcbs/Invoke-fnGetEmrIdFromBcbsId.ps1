function Invoke-fnGetEmrIdFromBcbsId {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$bcbsId
    )
    
    $StoredProcedure = 'dbo.spGetEmrIdFromBcbsId'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get EMR ID equivalent to BCBS ID"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BcbsId", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $bcbsId

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($workstation.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Information -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}