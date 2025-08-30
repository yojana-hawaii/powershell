function Invoke-fnSpWorkstationReboot{
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$frequency
    )

    $StoredProcedure = 'dbo.spGetComputerReboot'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Get Computers to reboot."

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@frequency", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $frequency


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