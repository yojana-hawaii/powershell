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

    $hpScanConfig  = Get-fnHpScannerConfig 
    
    # set all the constants in hash table. variable are set as blank key-value
    $hash = @{
        userDirPrefix="\\"
        userDirSuffix="\c$\users\"
        userDir=""
        compName=""

        excludeProfiles = ("$($hpScanConfig.excludeProfiles)"  -replace '"',"") -split(";")

        hp_path="\AppData\Local\HP"
        hp_alt_path="\HP Scan"
        hp_s3="\HP ScanJet Pro 3000 s3\"
        hp_s4="\HP ScanJet Pro 3000 s4\"

        scanner_profile_name="ATHENA_SCAN"
        default_username="newUser"

        s3_src_ini_file=$hpScanConfig.s4fileLocation  -replace '"',""
        s4_src_ini_file=$hpScanConfig.s3FileLocation  -replace '"',""
        s3_sha256=""
        s4_sha256=""
        src_sha256=""
    }
    Remove-Variable hpScanConfig

    # to compare file
    $hash.s3_sha256 = (Get-FileHash -Path $hash.s3_src_ini_file -Algorithm SHA256).hash
    $hash.s4_sha256 = (Get-FileHash -Path $hash.s4_src_ini_file -Algorithm SHA256).hash

    # change comp1 to specific computer to target one machine
    $comp = "comp1"
    if($comp -eq "comp1"){
        $computers = Invoke-spGetHpScannerComputer

        foreach($computer in $computers){
            Write-Verbose "Working on $computer"
            $hash.compName = $computer.ComputerName
            Get-fnUserProfileAndPushHpScannerConfig -hash $hash
        }
    } else {
        $hash.compName = $comp
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
