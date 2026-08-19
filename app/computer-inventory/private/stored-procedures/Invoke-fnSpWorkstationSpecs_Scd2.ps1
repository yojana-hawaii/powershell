function Invoke-fnSpWorkstationSpecs_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$workstation
    )

    $StoredProcedure = 'dbo.spWorkstationSpecs_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($workstation.ComputerName)"

        
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsLaptop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsDesktop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsThinClient", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsServer", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsVm", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsVpn", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SerialNumber", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BiosVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BiosReleaseDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Manufacturer", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Model", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@WakeUpType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CurrentUser", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@RamInstalledGb", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@RamUpgradableGb", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@RamSlotTotal", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@RamSlotUsed", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Processor", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@NumberOfCores", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@NumberOfEnabledCore", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CurrentClockSpeed", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskModel", [System.Data.SqlDbType]::Varchar, 1000)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskSizeGb", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TpmEnabled", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TpmVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@MacAddresses", [System.Data.SqlDbType]::Varchar, 300)))|Out-Null
        
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastRebootDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@EncryptionLevel", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OsArchitecture", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@NumberOfUsers", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OsBuildNumber", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OsBuildType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OsVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OsCountryCode", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastSecurityUpdateDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastSecurityUpdate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastPatch", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastPatchDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        

        $cmd.Parameters[0].Value = $workstation.ComputerName
        $cmd.Parameters[1].Value = $workstation.IsLaptop
        $cmd.Parameters[2].Value = $workstation.IsDesktop
        $cmd.Parameters[3].Value = $workstation.IsThinClient
        $cmd.Parameters[4].Value = $workstation.IsServer
        $cmd.Parameters[5].Value = $workstation.IsVm
        $cmd.Parameters[6].Value = $workstation.IsVpn
        $cmd.Parameters[7].Value = $workstation.SerialNumber
        $cmd.Parameters[8].Value = $workstation.BiosVersion
        $cmd.Parameters[9].Value = $workstation.BiosReleaseDate
        $cmd.Parameters[10].Value = $workstation.Manufacturer
        $cmd.Parameters[11].Value = $workstation.Model
        $cmd.Parameters[12].Value = $workstation.WakeUpType
        $cmd.Parameters[13].Value = $workstation.CurrentUser
        $cmd.Parameters[14].Value = $workstation.RamInstalledGb
        $cmd.Parameters[15].Value = $workstation.RamUpgradableGb
        $cmd.Parameters[16].Value = $workstation.RamSlotTotal
        $cmd.Parameters[17].Value = $workstation.RamSlotUsed
        $cmd.Parameters[18].Value = $workstation.Processor
        $cmd.Parameters[19].Value = $workstation.NumberOfCores
        $cmd.Parameters[20].Value = $workstation.NumberOfEnabledCore
        $cmd.Parameters[21].Value = $workstation.CurrentClockSpeed
        $cmd.Parameters[22].Value = $workstation.DiskModel
        $cmd.Parameters[23].Value = $workstation.DiskSizeGb
        $cmd.Parameters[24].Value = $workstation.DiskType
        $cmd.Parameters[25].Value = $workstation.TpmEnabled
        $cmd.Parameters[26].Value = $workstation.TpmVersion
        $cmd.Parameters[27].Value = $workstation.MacAddresses
        $cmd.Parameters[28].Value = $workstation.LastRebootDate
        $cmd.Parameters[29].Value = $workstation.EncryptionLevel
        $cmd.Parameters[30].Value = $workstation.OsArchitecture
        $cmd.Parameters[31].Value = $workstation.NumberOfUsers
        $cmd.Parameters[32].Value = $workstation.OsBuildNumber
        $cmd.Parameters[33].Value = $workstation.OsBuildType
        $cmd.Parameters[34].Value = $workstation.OsVersion
        $cmd.Parameters[35].Value = $workstation.OsCountryCode
        $cmd.Parameters[36].Value = $workstation.LastSecurityUpdateDate
        $cmd.Parameters[37].Value = $workstation.LastSecurityUpdate
        $cmd.Parameters[38].Value = $workstation.LastPatch
        $cmd.Parameters[39].Value = $workstation.LastPatchDate

        
        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}