set-location "\\fileserver\it\apps\powershell"

function New-fnInsuranceGapsInCare {
    [CmdletBinding()]
    param (
        
    )
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnFilesandFolderConfig.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\bcbs\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config             = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\bcbs\*.ps1" -ErrorAction SilentlyContinue -Recurse) 

    

    foreach ($import in @($configHelper + $utility + $private + $sqlConection + $config + $storedProcedure)){
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
    $filesConfig    = Get-fnFilesandFolderConfig
    $emrFile        = ($filesConfig.patientAndInsurance) -replace '"',""
    $bcbsFile       = ($filesConfig.insuranceAndPatient) -replace '"',""
    $insurance      = ($filesConfig.insuranceValidation) -replace '"',""
    $demographics   = ($filesConfig.patientValidation) -replace '"',""
    $noMatch        = ($filesConfig.noMatchValidation) -replace '"',""
    $folderPath     = ($filesConfig.gapsFolder) -replace '"',""
    
    Update-fnEmrAndBcbsDataMatchingAlgorithm -bcbsFile $bcbsFile -emrFile $emrFile
    Export-fnHumanAiValidation -insuranceAi $insurance -demographicsAi $demographics -noMatchAi $noMatch # export for ai validation
    Add-fnGapsDataToBsbc -FilePath $bcbsFile -ClinicalAiPath $folderPath
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$Global:today = $null
$today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
New-fnInsuranceGapsInCare  -Verbose -InformationAction Continue
Stop-Transcript
