set-location "\\fileserver\it\apps\powershell"

function New-fnOrderReport {
    #region - Import necessary configs and private functions #>

    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\orders\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnEmailConfig.ps1" -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $emailConf)){
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

    Write-Verbose "$($MyInvocation.MyCommand.Name): Initializing order and email configs."
    $order = Initialize-fnOrderConfigs
    $email = Initialize-fnOrderEmailConfigs 

    $sendEmail = $false
    $staffEmail = $false
    $OrdersToDelete = $null
    $email.emailBody4 = @{}
    $email.emailBody5 = $null
    $email.emailBody6 = @{}


    Write-Verbose "$($MyInvocation.MyCommand.Name): Looping through $($order.type)"
    for($i=0; $i -le ($order.Count - 1); $i++){
        Write-Verbose "$($MyInvocation.MyCommand.Name): Current loop $($order[$i].type )"

        if( -not (Test-fnSourceFile -sourceFile $order[$i].source -sourceFileValidDays 7) ){
            Update-fnInvalidSource -email $email -type $order[$i].type -sourceFile $order[$i].source 
            $sendEmail = $true
        } else {

            if (Test-fnDestinationFile -sourceFile $order[$i].source -destinationFile $order[$i].extDestination ){
                Update-fnValidSourceAndDestination -email $email -type $order[$i].type
            }
            else {
                $order[$i] =  Update-fnInValidDestination -email $email -order $order[$i]
                $sendEmail = $true
                $staffEmail = $true

                $OrdersToDelete += $order[$i].deletedata
            }
        }    
    }
        
    if($sendEmail) {
        Set-fnEmailBodyOrder -email $email
        Set-fnEmailHtmlCombine -email $email
        Send-MailMessage -From $email.from -To $email.to -Cc $email.cc  -Subject $email.subject -Body $email.body -SmtpServer $email.smtp -BodyAsHtml

        $OrdersToDelete | Where-Object {$null -ne $_ }| Export-csv -Path "$($order[0].delDestination)\delete.csv" -NoTypeInformation
    }
    
    if($staffEmail){
        Send-fnIncompleteLabToSupportStaff -orderPath $order[0].extDestination -supportStaffPath $order[0].supportStaff -email $email
    }
    
    

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Order summary export and email complete. It took $totalTime"    
}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnOrderReport -Verbose -InformationAction continue
Stop-Transcript