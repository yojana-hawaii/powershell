function Invoke-spGetComputersToScan {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$count,
        [parameter()]
        [string]$scanAfterDays
    )

    
    $StoredProcedure = 'dbo.spGetComputersToScan'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Get Computers to scan."

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@count", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@scanAfterDays", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $count
        $cmd.Parameters[1].Value = $scanAfterDays


        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed : $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}