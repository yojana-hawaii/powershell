function Invoke-spGetAdmins {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$days = -7
    )

    
    $StoredProcedure = 'dbo.spGetAdmins'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure -database "DaHubAide"
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Get sysaid admins."

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@days", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        
        $cmd.Parameters[0].Value = $days        


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