function Invoke-spAdComputer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$computer
    )

    
    $StoredProcedure = 'dbo.spAdComputers'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($computer.ComputerName)"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Enabled", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HasBitlocker", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@hasLaps", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DistinguishedName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OU", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sAMAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IPV4Address", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OperatingSystem", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OperatingSystemVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Description", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CreatedDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ModifiedDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BitLockerPasswordDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LapsExpirationDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastLogonDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LogonCount", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserAccountControl", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $computer.ComputerName

        $cmd.Parameters[1].Value = $computer.Enabled
        $cmd.Parameters[2].Value = $computer.HasBitlocker
        $cmd.Parameters[3].Value = $computer.hasLaps

        $cmd.Parameters[4].Value = $computer.DistinguishedName
        $cmd.Parameters[5].Value = $computer.OU
        $cmd.Parameters[6].Value = $computer.sAMAccountName
        $cmd.Parameters[7].Value = $computer.IPV4Address
        $cmd.Parameters[8].Value = $computer.OperatingSystem
        $cmd.Parameters[9].Value = $computer.OperatingSystemVersion
        $cmd.Parameters[10].Value = $computer.Description

        $cmd.Parameters[11].Value = $computer.CreatedDate
        $cmd.Parameters[12].Value = $computer.ModifiedDate
        $cmd.Parameters[13].Value = $computer.BitLockerPasswordDate
        $cmd.Parameters[14].Value = $computer.LapsExpirationDate
        $cmd.Parameters[15].Value = $computer.LastLogonDate

        $cmd.Parameters[16].Value = $computer.LogonCount
        $cmd.Parameters[17].Value = $computer.UserAccountControl

       $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computer.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}