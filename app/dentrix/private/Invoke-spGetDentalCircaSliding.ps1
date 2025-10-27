
function Invoke-spGetDentalCircaSliding {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$start,
        [string]$end,
        [string]$payer
    )
    $StoredProcedure = 'dbo.spDentalSlidingCyrca'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get $($something)"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@startdate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@enddate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@insurance", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters[0].Value = $start
        $cmd.Parameters[1].Value = $end
        $cmd.Parameters[2].Value = $payer
        

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed : $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}