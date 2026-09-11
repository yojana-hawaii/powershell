set-location "\\fileserver\it\apps\powershell"

function Add-fnHpScannerProfile{
    #region - Import necessary configs and private functions #>
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $private    = @(Get-ChildItem -Path "$PWD\app\hp-scanner-config\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlLookup  = @(Get-ChildItem -Path "$PWD\shared\SqlLookup\Invoke-spGetHpScannerComputer.ps1"    -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $sqlConn + $config + $emailConf + $private + $sqlLookup )){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, sqlConn, config, emailConf, private, sqlLookup
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    
    # set all the constants in hash table. variable are set as blank key-value
    $hash = Get-fnHpScanObject

    $hash.s3_modified_date = (Get-ChildItem -Path $hash.s3_src_ini_file).LastWriteTime
    $hash.s4_modified_date = (Get-ChildItem -Path $hash.s4_src_ini_file).LastWriteTime

    # change comp1 to specific computer to target one machine
    $comp = "comp1"
    if($comp -eq "comp1"){
        write-host "change $comp to computer name"
        # $computers = Invoke-spGetHpScannerComputer

        # foreach($computer in $computers){
        #     Write-Verbose "Working on $computer"
        #     $hash.srcCompName = $computer.ComputerName
        #     Get-fnUserProfileAndPushHpScannerConfig -hash $hash
        # }
    } else {
        $hash.srcCompName = $comp
        Get-fnUserProfileAndPushHpScannerConfig -hash $hash
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
$InformationPreference = "continue"
Add-fnHpScannerProfile -Verbose -InformationAction continue
Stop-Transcript
