function Split-fnComputersByType {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Split all computer list"

    #try cath when there is possibility of exception
    try { 
        $param.Server =     $param.all | Where-Object {$_.IsServer -eq 1}
        $param.Unscanned =  $param.all | Where-Object {$_.IsNeverScanned -eq 1}
        $param.ThinClient = $param.all | Where-Object {$_.IsThinClient -eq 1}
        $param.UserVm =     $param.all | Where-Object {$_.IsServer -eq 0 -and $_.IsVm -eq 1}
        $param.OldEncryption = $param.all | Where-Object {$_.IsServer -eq 0 -and $_.IsVm -eq 0 -and $_.DellEncryptionService -eq 1}
        $param.Windows10 = $param.all | Where-Object {$_.OperatingSystem -eq "win-10" -and $_.DellEncryptionService -eq 0}
        $param.Windows11NeedWork = $param.all | Where-Object {
                $_.OperatingSystem -eq "win-11" -and $_.IsVm -eq 0 -and -not (
                    $_.DellEncryptionService -eq 0 -and $_.KaceService -eq 1 -and $_.SentinelOneService -eq 1 -and
                    $_.HasBitlocker -eq 1 -and $_.IsSdd -eq 1 -and $_.SysaidService -eq 1
                )  
            }
        $param.Windows11Good = $param.all | Where-Object {
                $_.OperatingSystem -eq "win-11" -and $_.IsVm -eq 0 -and (
                    $_.DellEncryptionService -eq 0 -and $_.KaceService -eq 1 -and $_.SentinelOneService -eq 1 -and
                    $_.HasBitlocker -eq 1 -and $_.IsSdd -eq 1 -and $_.SysaidService -eq 1
                )  
            }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}