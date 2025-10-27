
set-location "\\fileserver\it\apps\powershell"
function Get-fnCyrcaSliding{
    #region - Import necessary configs and private functions #>

    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\dentrix\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
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
    Remove-Variable import, utility, private, sqlConn, emailConf
    #endregion
    
    $startTimer = Start-Timer
    $denConf    = Get-fnDentrixConfig
    $exportPath   = ($denConf.exportPath)-replace '"',""
    $payer   = ($denConf.payer3)-replace '"',""

    $date = Get-Date -Format "yyyy-MM-dd"
    
    $dimdate = Invoke-spGetDimDateDetails -param $date
    $start = Get-Date $dimdate.FiscalStart -Format "yyyy-MM-dd"
    $end = Get-Date $dimdate.FiscalEnd -Format "yyyy-MM-dd"
    $file = "$($dimdate.FiscalYear) Dental $($payer.Replace(",", " ")).xlsx"
    $path = Join-Path -Path $exportPath -ChildPath $file
    $sheet = "As of $date"
    
    $data = Invoke-spGetDentalCircaSliding -start $start -end $end -payer $payer
    try {
        $data | Select-Object PatientId, Name, 
            @{Label="DoB" 
                Expression={Get-Date $_.BirthDate -Format "MM/dd/yyyy"} }, 
            Gender, Race, ClinicName, Insurance, 
            @{label="ServiceDate"
                Expression={Get-Date $_.ServiceDate -Format "MM/dd/yyyy"}}, AdaCode | 
        Export-Excel -Path $path -WorksheetName $sheet -AutoSize
        
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    
    $emailConfig =  Get-fnEmailConfig
    $email = Initialize-fnEmailConfig -param $emailConfig
    Set-fnDentalCyrcaEmailConfig -email $email
    Send-fnEmail -email $email
    Reset-fnEmailConfig -email $email


    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Get-fnCyrcaSliding -Verbose -InformationAction continue
Stop-Transcript
