function Invoke-fnSpWorkstationLocalUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$localUser
    )

    
    $StoredProcedure = 'dbo.spWorkstationLocalUsers'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($localUser.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordExpires", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Disabled", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LocalAccount", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Lockout", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordChangeable", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordRequired", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Fullname", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Description", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Status", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AccountType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@InstallDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $localUser.ComputerName
        $cmd.Parameters[1].Value = $localUser.PasswordExpires
        $cmd.Parameters[2].Value = $localUser.Disabled
        $cmd.Parameters[3].Value = $localUser.LocalAccount
        $cmd.Parameters[4].Value = $localUser.Lockout
        $cmd.Parameters[5].Value = $localUser.PasswordChangeable
        $cmd.Parameters[6].Value = $localUser.PasswordRequired
        $cmd.Parameters[7].Value = $localUser.Name
        $cmd.Parameters[8].Value = $localUser.FullName
        $cmd.Parameters[9].Value = $localUser.Description
        $cmd.Parameters[10].Value = $localUser.Status
        $cmd.Parameters[11].Value = $localUser.AccountType
        $cmd.Parameters[12].Value = $localUser.InstallDate


        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($localUser.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}