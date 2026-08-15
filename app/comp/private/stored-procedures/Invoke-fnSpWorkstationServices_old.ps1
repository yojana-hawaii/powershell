function Invoke-fnSpWorkstationServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$service,
        [Parameter(Mandatory)]
        [string]$computerName
    )
    
    $StoredProcedure = 'dbo.spWorkstationServices'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($service.Name) to $($ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceDisplayName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceState", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStartMode", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceAcceptPause", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceAcceptStop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceDelayedAutoStart", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStartName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
  
        $cmd.Parameters[0].Value = $ComputerName
        $cmd.Parameters[1].Value = $service.Name
        $cmd.Parameters[2].Value = $service.DisplayName
        $cmd.Parameters[3].Value = $service.State
        $cmd.Parameters[4].Value = $service.StartMode
        $cmd.Parameters[5].Value = $service.AcceptPause
        $cmd.Parameters[6].Value = $service.AcceptStop
        $cmd.Parameters[7].Value = $service.DelayedAutoStart
        $cmd.Parameters[8].Value = $service.StartName

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($service.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}