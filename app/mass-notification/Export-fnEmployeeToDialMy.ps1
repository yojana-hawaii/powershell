function Export-fnEmployeeToDialMy {
    
    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    #region - Import necessary configs and private functions #>
   
    $private    = @(Get-ChildItem -Path "$PWD\app\mass-notification\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $org        = @(Get-ChildItem -Path "$PWD\shared-ignore\organization-specific\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($private + $emailConf + $org + $utility)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 
    
    #region Initialize
    Write-Information "Initialize config from employee config file."
    $dialMy = Get-fnMassNotificationConfig

    Write-Information "Strip `" (double quote). Pull path from config file adds double quotes everywhere"
    $sourceFile                     = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.employeeSourceFilename) -replace '"',""
    $additionalPhoneNumbersFile     = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.additionalPhoneNumbers) -replace '"',""
    $dialMyCsv                      = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.dialMyCsv) -replace '"',""
    $activeDirectoryCsv             = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.activeDirectoryCsv) -replace '"',""
    $azureDirectoryCsv              = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.azureDirectoryCsv) -replace '"',""
    $validateCsv                    = (Join-Path -Path $dialMy.employeeFilepath -ChildPath $dialMy.validateCsv) -replace '"',""
    $org2                           = ($dialMy.organization2) -replace '"',""
    $sourceFileHeader               = ($dialMy.sourceFileHeader) -replace '"',""

    $emailConf =  Get-fnEmailConfig

    $email = @{
        Smtp            = ($emailConf.smtp) -replace '"',""
        To              = ($emailConf.helpdesk) -replace '"',""
        From            = ($emailConf.myEmail) -replace '"',""
        Sig             = ($emailConf.mySig) -replace '"',""
        Subject         = ($emailConf.proserviceSubject) -replace '"',""
        Body            = ""
    }
    #endregion

    $employees = Convert-fnCsvToEmployee -sourceFile $sourceFile -org2 $org2 -sourceFileHeader $sourceFileHeader
    $employees = Add-fnMissingPhoneNumbers -employees $employees -additionalPhoneNumbersFile $additionalPhoneNumbersFile

    $employees | Select-Object Last,First,cellPhone,dialGroup | Export-csv -Path $dialMyCsv -NoTypeInformation
    $employees | Select-Object Last,First,hrEmail,cellPhone,staffEmail,manager,managerEmail,location,department,jobtitle,orgGroup | Export-csv -Path $validateCsv -NoTypeInformation
    $employees | Where-Object {$_.department -ne $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $activeDirectoryCsv -NoTypeInformation
    $employees | Where-Object {$_.department -eq $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $azureDirectoryCsv -NoTypeInformation
        
    

    $failedUsers = Set-fnActiveDirectoryUpdate -CsvPath $activeDirectoryCsv

    $userStr = ""
    foreach($user in $failedUsers){
        $userStr += "$($user.First) $($user.Last) ($($user.Email)) - $($user.manager) <br>"
    }

    $issue = if($userStr) {"Users with impport issue: <br> $userStr"} else {"No issues importing"}

    $email.body = "Hello all, This is an automated email." + 
            "<p>Proservice cell phone number to files ready to be uploaded in Dial My Calls. Issue with SFTP server in DMZ has wrong Gateway.</p>
            <p>Proservice manager, job title, department & location uploaded to Active Directory with minor clean up. Following users cannot be updated automatically.  </p>
            <p>Possible issues
            <ul>
            <li>Username in AD does follow convention</li>
            <li>Email in AD does not follow convention</li> 
            <li>Proservice has terminated employee as manager</li> 
            </ul>
            </p>
            $issue
            <br><br>Thank you.<br>$($email.Sig)"

    Send-MailMessage -smtpserver $email.smtp -from $email.from -to $email.to -subject $email.subject -body $email.body -bodyashtml

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Proservice employee data to Dial My Call & Actice Directory. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Export-fnEmployeeToDialMy -Verbose -InformationAction continue
Stop-Transcript
