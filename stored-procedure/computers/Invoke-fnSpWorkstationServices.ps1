function Invoke-fnSpWorkstationServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$workstation
    )
    
    $StoredProcedure = 'dbo.spWorkstationServices'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($workstation.Name) to $($workstation.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceDisplayName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStatus", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceStartType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanPauseAndContinue", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanShutdown", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ServiceCanStop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
  
        $cmd.Parameters[0].Value = $workstation.ComputerName
        $cmd.Parameters[1].Value = $workstation.Name
        $cmd.Parameters[2].Value = $workstation.DisplayName
        $cmd.Parameters[3].Value = $workstation.Status
        $cmd.Parameters[4].Value = $workstation.StartType
        $cmd.Parameters[5].Value = $workstation.CanPauseAndContinue
        $cmd.Parameters[6].Value = $workstation.CanShutdown
        $cmd.Parameters[7].Value = $workstation.CanStop

        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed with return $($return): $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($workstation.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}