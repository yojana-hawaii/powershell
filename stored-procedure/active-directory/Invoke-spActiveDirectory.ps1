function Invoke-spActiveDirectory {
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Collections.DictionaryEntry]$ActiveDirectory
    )
    $StoredProcedure = 'dbo.spActiveDirectory'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]
    try{
        Write-Verbose -Message "Insert $($ActiveDirectory.Name)"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@name", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@value", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $ActiveDirectory.Name
        $cmd.Parameters[1].Value = $ActiveDirectory.Value
        
        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}