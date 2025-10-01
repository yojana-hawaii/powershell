set-location "\\fileserver\it\apps\powershell"

function Export-fnComputerTaskList{
    #region - Import necessary configs and private functions #>

    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\computer-export\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    
    foreach ($import in @($utility + $private + $sqlConn + $config)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    $import = $null
    #endregion
    
    $startTimer = Start-Timer
    $exportConf = Get-fnComputerExportConfig

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
        Root = ($exportConf.root) -replace '"', ""
        Extension = ($exportConf.extension) -replace '"', ""
    }
    
    try { 
        $computerHash.All = Invoke-fnSpGetComputerTaskList
        Split-fnComputersByType -param $computerHash
        Export-fnSplitTaskListToExcel -param $computerHash

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Export computer task lists complete. It took $totalTime"    
}
$Global:today = Get-Date # user by Test-fnSourceFile and maybe others
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Export-fnComputerTaskList -Verbose -InformationAction continue
Stop-Transcript
