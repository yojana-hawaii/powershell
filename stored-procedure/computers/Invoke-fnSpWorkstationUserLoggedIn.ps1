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
        Write-Verbose -Message "Insert $($loggedInUser.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserLoggedIn", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserLastLoggedInDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $loggedInUser.ComputerName
        $cmd.Parameters[1].Value = $loggedInUser.UserLoggedIn
        $cmd.Parameters[2].Value = $loggedInUser.UserLastLoggedInDate

        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($loggedInUser.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}