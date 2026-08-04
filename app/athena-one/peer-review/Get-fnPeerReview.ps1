set-location "\\fileserver\it\apps\powershell"

function Get-fnPeerReview{
    #region - Import necessary configs and private functions #>
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private    = @(Get-ChildItem -Path "$PWD\app\athena-one\peer-review\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $athenaConf = @(Get-ChildItem -Path "$PWD\app\athena-one\config\Get-fnAthenaConfig.ps1"    -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $private + $athenaConf)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    # Remove-Variable import, utility, private, athenaConf
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start peer reivew process from uds includsion table" 
    Import-Module ImportExcel

    $hash = Get-fnPeerReviewObject
    Get-fnQualifiyingVisits -hash $hash
    Get-fnSelectRandomVisits -hash $hash 
    Export-fnPeerReviewFile -hash $hash

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
$InformationPreference = "continue"
Get-fnPeerReview -Verbose -InformationAction continue
Stop-Transcript
