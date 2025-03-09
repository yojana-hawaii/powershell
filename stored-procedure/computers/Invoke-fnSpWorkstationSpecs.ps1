function Invoke-fnSpWorkstationSpecs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$workstation
    )

    $StoredProcedure = 'dbo.spWorkstationSpecs'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($workstation.ComputerName)"

        
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SerialNumber", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
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
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsLaptop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsDesktop", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsThinClient", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsServer", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsVm", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsVpn", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $workstation.ComputerName
        $cmd.Parameters[1].Value = $workstation.SerialNumber
        $cmd.Parameters[2].Value = $workstation.BiosVersion
        $cmd.Parameters[3].Value = $workstation.BiosReleaseDate
        $cmd.Parameters[4].Value = $workstation.Manufacturer
        $cmd.Parameters[5].Value = $workstation.Model
        $cmd.Parameters[6].Value = $workstation.WakeUpType
        $cmd.Parameters[7].Value = $workstation.CurrentUser
        $cmd.Parameters[8].Value = $workstation.RamInstalledGb
        $cmd.Parameters[9].Value = $workstation.RamUpgradableGb
        $cmd.Parameters[10].Value = $workstation.RamSlotTotal
        $cmd.Parameters[11].Value = $workstation.RamSlotUsed
        $cmd.Parameters[12].Value = $workstation.Processor
        $cmd.Parameters[13].Value = $workstation.NumberOfCores
        $cmd.Parameters[14].Value = $workstation.NumberOfEnabledCore
        $cmd.Parameters[15].Value = $workstation.CurrentClockSpeed
        $cmd.Parameters[16].Value = $workstation.DiskModel
        $cmd.Parameters[17].Value = $workstation.DiskSizeGb
        $cmd.Parameters[18].Value = $workstation.DiskType
        $cmd.Parameters[19].Value = $workstation.TpmEnabled
        $cmd.Parameters[20].Value = $workstation.TpmVersion
        $cmd.Parameters[21].Value = $workstation.MacAddresses
        $cmd.Parameters[22].Value = $workstation.LastRebootDate
        $cmd.Parameters[23].Value = $workstation.EncryptionLevel
        $cmd.Parameters[24].Value = $workstation.OsArchitecture
        $cmd.Parameters[25].Value = $workstation.NumberOfUsers
        $cmd.Parameters[26].Value = $workstation.OsBuildNumber
        $cmd.Parameters[27].Value = $workstation.OsBuildType
        $cmd.Parameters[28].Value = $workstation.OsVersion
        $cmd.Parameters[29].Value = $workstation.OsCountryCode
        $cmd.Parameters[30].Value = $workstation.LastSecurityUpdateDate
        $cmd.Parameters[31].Value = $workstation.LastSecurityUpdate
        $cmd.Parameters[32].Value = $workstation.LastPatch
        $cmd.Parameters[33].Value = $workstation.LastPatchDate

        $cmd.Parameters[34].Value = $workstation.IsLaptop
        $cmd.Parameters[35].Value = $workstation.IsDesktop
        $cmd.Parameters[36].Value = $workstation.IsThinClient
        $cmd.Parameters[37].Value = $workstation.IsServer
        $cmd.Parameters[38].Value = $workstation.IsVm
        $cmd.Parameters[39].Value = $workstation.IsVpn


        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}