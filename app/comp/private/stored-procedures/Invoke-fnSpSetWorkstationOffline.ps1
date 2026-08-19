function Invoke-fnSpSetWorkstationOffline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )

    
    $StoredProcedure = 'dbo.spSetWorkstationOffline'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($computerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $computerName

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
    
}