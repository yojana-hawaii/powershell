function Set-fnOrganizeLogFiles {
    [CmdletBinding()]
    param ()
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnFilesAndFolderConfig.ps1"   -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\files-and-folders\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)

  
    foreach ($import in @($private + $configHelper + $utility)){
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
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."

    $config = Get-fnFilesAndFolderConfig 

    $powershellLogSource = "$($config.powershellLogSource)"  -replace '"',""
    $txtExtension = "$($config.txtExtension)"  -replace '"',""
    Set-fnMoveFilesByLastModified -source $powershellLogSource -extension $txtExtension
    Set-fnArchiveAndDelete -source $powershellLogSource
    

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): orgnanize. It took $totalTime" 
  }
  
  $Global:today = $null
  $today = Get-Date
  $filenameAppend = Get-Date -Format "yyyMMddHHmm"
  
  Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
  Set-fnOrganizeLogFiles -Verbose -InformationAction Continue 
  Stop-Transcript