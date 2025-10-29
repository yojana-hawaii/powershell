function Invoke-spGetUserAndManagerDetails {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$username
    )
    $StoredProcedure = 'dbo.spGetUserAndManagerDetails'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get manager of $username"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@username", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters[0].Value = $username
        

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