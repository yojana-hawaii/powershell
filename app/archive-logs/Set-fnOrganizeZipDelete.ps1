set-location "\\fileserver\it\apps\powershell"

function Set-fnOrganizeZipDelete{
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\archive-logs\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private
    #endregion
    
    $startTimer     = Start-Timer

    $achiveConfig = Get-fnArchiveConfig
    $psLog = "$($achiveConfig.psLog)"  -replace '"',""
    $psLogExt = "$($achiveConfig.psLogExt)"  -replace '"',""
    $dc1 = "$($achiveConfig.dc1Event)"  -replace '"',""
    $dc2 = "$($achiveConfig.dc2Event)"  -replace '"',""
    $dc3 = "$($achiveConfig.dc3Event)"  -replace '"',""
    
    $eventFilePrefixToArchive = "$($achiveConfig.eventFilePrefixToArchive)"  -replace '"',""
    $eventExtension = "$($achiveConfig.eventExtension)"  -replace '"',""

    Move-fnFilesIntoYearMonthDayFolders -source $psLog -extension $psLogExt -filePrefix 'all'
    Start-fnZipAndDelete -path $psLog -daysToWait 14

    Move-fnFilesIntoYearMonthDayFolders -source $dc1 -extension $eventExtension -filePrefix $eventFilePrefixToArchive
    Start-fnZipAndDelete -path $dc1 -daysToWait 3
    Move-fnFilesIntoYearMonthDayFolders -source $dc2 -extension $eventExtension -filePrefix $eventFilePrefixToArchive
    Start-fnZipAndDelete -path $dc2 -daysToWait 3
    Move-fnFilesIntoYearMonthDayFolders -source $dc3 -extension $eventExtension -filePrefix $eventFilePrefixToArchive
    Start-fnZipAndDelete -path $dc3 -daysToWait 3



    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnOrganizeZipDelete -Verbose -InformationAction continue
Stop-Transcript
