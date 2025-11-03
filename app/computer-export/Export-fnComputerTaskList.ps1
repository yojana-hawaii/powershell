set-location "\\fileserver\it\apps\powershell"

function Export-fnComputerTaskList{
    #region - Import necessary configs and private functions #>

    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\computer-export\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $excel      = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnExcelExportConfig.ps1" -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($utility + $private + $sqlConn + $config + $emailConf + $excel)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf,excel
    #endregion
    
    $startTimer = Start-Timer

    $computerHash = [hashtable]@{
        All = ""
        Server = ""
        Unscanned = ""
        ThinClient = ""
        UserVm = ""
        OldEncryption = ""
        Windows10 = ""
        Windows11NeedWork = ""
        Windows11Good = ""
        Root = ($exportConf.computerExportPath) -replace '"', ""
        Extension = ($exportConf.extension) -replace '"', ""
    }
    
    try { 
        $computerHash.All = Invoke-fnSpGetComputerTaskList
        Split-fnComputersByType -param $computerHash
        Export-fnSplitTaskListToExcel -param $computerHash

        $email = Initialize-fnEmailConfig
        Get-fnEmailConfig_CompExport -email $email -param $computerHash
        Send-fnEmail -email $email

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Export computer task lists complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Export-fnComputerTaskList -Verbose -InformationAction continue
Stop-Transcript
