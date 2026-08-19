set-location "\\fileserver\it\apps\powershell"
function New-fnMissingSlip {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\missing-slip\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $config + $emailConf)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf

    #endregion
    
    $startTimer = Start-Timer

    Write-Verbose "$($MyInvocation.MyCommand.Name): start."

    #region Initialize Config
    $config = Get-fnMissingSlipConfig   
    $source = "$($config.missingSlipSource)"  -replace '"',""
    #endregion
    
    $sourceValid = Test-fnSourceFile -sourceFile $source -sourceFileValidDays 2

    if($sourceValid){
        $data = Import-Excel $source
        $groupByProvider = $data | Group-Object 'Rendering Provider'

        foreach($prov in $groupByProvider){
            $email = Initialize-fnEmailConfig
            Get-fnEmailConfig_MissingSlip -email $email -providerDetails $prov            
            Send-fnEmail -email $email
        }
    } else {
        Write-Warning "Missing slip file too old"
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Missing slip email sent. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnMissingSlip -Verbose -InformationAction continue
Stop-Transcript