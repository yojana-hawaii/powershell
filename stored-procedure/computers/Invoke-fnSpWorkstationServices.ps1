function Invoke-fnSpWorkstationServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$service
    )
    
    $StoredProcedure = 'dbo.spWorkstationServices'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($service.Name) to $($service.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceDisplayName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStatus", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStartType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanPauseAndContinue", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanShutdown", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanStop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
  
        $cmd.Parameters[0].Value = $service.ComputerName
        $cmd.Parameters[1].Value = $service.Name
        $cmd.Parameters[2].Value = $service.DisplayName
        $cmd.Parameters[3].Value = $service.Status
        $cmd.Parameters[4].Value = $service.StartType
        $cmd.Parameters[5].Value = $service.CanPauseAndContinue
        $cmd.Parameters[6].Value = $service.CanShutdown
        $cmd.Parameters[7].Value = $service.CanStop

        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed with return $($return): $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($service.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}