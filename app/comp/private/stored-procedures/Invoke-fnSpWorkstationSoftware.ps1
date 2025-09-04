function Invoke-fnSpWorkstationSoftware {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$software
    )

    
    $StoredProcedure = 'dbo.spWorkstationSoftware'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($software.SoftwareName) to $($software.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareVendor", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareInstallDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareInstallLocation", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareInstallSource", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $software.ComputerName
        $cmd.Parameters[1].Value = $software.SoftwareName
        $cmd.Parameters[2].Value = $software.SoftwareVersion
        $cmd.Parameters[3].Value = $software.SoftwareVendor
        $cmd.Parameters[4].Value = $software.SoftwareInstallDate
        $cmd.Parameters[5].Value = $software.SoftwareInstallLocation
        $cmd.Parameters[6].Value = $software.SoftwareInstallSource

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($software.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
       Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}