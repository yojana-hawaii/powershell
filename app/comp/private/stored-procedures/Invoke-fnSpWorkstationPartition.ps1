function Invoke-fnSpWorkstationPartition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$parition
    )

    
    $StoredProcedure = 'dbo.spWorkstationPartition'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        write-information -Message "Insert $($parition.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PartitionNumber", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskNumber", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsBoot", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsHidden", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsSystem", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsReadOnly", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsOffline", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsActive", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DriveLetter", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PartitionSizeGb", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $parition.ComputerName
        $cmd.Parameters[1].Value = $parition.PartitionNumber
        $cmd.Parameters[2].Value = $parition.DiskNumber
        $cmd.Parameters[3].Value = $parition.IsBoot
        $cmd.Parameters[4].Value = $parition.IsHidden
        $cmd.Parameters[5].Value = $parition.IsSystem
        $cmd.Parameters[6].Value = $parition.IsReadOnly
        $cmd.Parameters[7].Value = $parition.IsOffline
        $cmd.Parameters[8].Value = $parition.IsActive
        $cmd.Parameters[9].Value = $parition.DriveLetter
        $cmd.Parameters[10].Value = $parition.PartitionSizeGb

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($parition.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}