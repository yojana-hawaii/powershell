set-location "\\fileserver\it\apps\powershell"

function Export-fnEmployeeData{
    #region - Import necessary configs and private functions #>
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $private    = @(Get-ChildItem -Path "$PWD\app\mass-notification\private\Get-fnMassNotificationConfig.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private2   = @(Get-ChildItem -Path "$PWD\app\mass-notification\private\function2\*.ps1" -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $emailConf + $private + $private2 )){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, emailConf, private, private2
    #endregion

    Import-Module ImportExcel
    
    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 
    $dialMyConf = Get-fnMassNotificationConfig

    $sourceFile = $dialMyConf.employeeFileV2 -replace '"',""
    $dialMyExcel = (Join-Path -Path $dialMyConf.employeeFilepath -ChildPath $dialMyConf.dialMyExcel) -replace '"',""
    
    try { 
        $data = Get-fnEmployeeData -Filename $sourceFile
        
        # $ceo = $dialMyConf.ceo -replace '"',""
        # $updateStatus = Set-fnUpdateUserInActiveDirectory -users $data -ceo $ceo

        $export = $data | 
            Select-Object 'First Name', 'Last Name', 'E-mail Address', Phone, Miscellaneous, "Group Assignments" 

        Remove-Item -Path $dialMyExcel -ErrorAction Ignore
        $export | Export-Excel -Path $dialMyExcel -AutoSize

        write-host "set up email"
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    
    # EMAIL CHANGES

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
$InformationPreference = "continue"
Export-fnEmployeeData -Verbose -InformationAction continue
Stop-Transcript
