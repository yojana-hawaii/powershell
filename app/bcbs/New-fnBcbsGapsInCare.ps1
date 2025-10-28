set-location "\\fileserver\it\apps\powershell"

function New-fnBcbsGapsInCare {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\bcbs\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
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
    Remove-Variable import, utility, private, sqlConn, config
    #endregion
    
    $startTimer     = Start-Timer
    $bcbsConfig     = Get-fnBcbsConfig
    $emrFile        = ($bcbsConfig.patientAndInsurance) -replace '"',""
    $bcbsFile       = ($bcbsConfig.insuranceAndPatient) -replace '"',""
    $insurance      = ($bcbsConfig.insuranceValidation) -replace '"',""
    $demographics   = ($bcbsConfig.patientValidation) -replace '"',""
    $noMatch        = ($bcbsConfig.noMatchValidation) -replace '"',""
    $folderPath     = ($bcbsConfig.gapsFolder) -replace '"',""
    

    Update-fnEmrAndBcbsDataMatchingAlgorithm -bcbsFile $bcbsFile -emrFile $emrFile
    Export-fnHumanAiValidation -insuranceAi $insurance -demographicsAi $demographics -noMatchAi $noMatch # export for ai validation
    Add-fnGapsDataToBsbc -FilePath $bcbsFile -ClinicalAiPath $folderPath
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnBcbsGapsInCare -Verbose -InformationAction continue
Stop-Transcript
