function Invoke-fnSpWorkstationUserLoggedIn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$loggedInUser
    )

    
    $StoredProcedure = 'dbo.spWorkstationUserLoggedIn'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($loggedInUser.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserLoggedIn", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserLastLoggedInDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $loggedInUser.ComputerName
        $cmd.Parameters[1].Value = $loggedInUser.UserLoggedIn
        $cmd.Parameters[2].Value = $loggedInUser.UserLastLoggedInDate

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($loggedInUser.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}