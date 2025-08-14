function Export-fnEmployeeToDialMy {
    [CmdletBinding()]
    param()



    #region - Import necessary configs and private functions #>

    Write-Verbose "Initialize private functions & config helpers in Export-fnEmployeeToDialMy.ps1"
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnEmployeeConfig.ps1"              -ErrorAction SilentlyContinue -Recurse)
    $emailConfig        = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnEmailConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\employee\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $org                = @(Get-ChildItem -Path "$PWD\private\organization-specific\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"  -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($configHelper + $private + $emailConfig + $org + $utility)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    $import = $null
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 
    
    #region Initialize
    Write-Verbose "Initialize config from employee config file."
    $config = Get-fnEmployeeConfig

    Write-Verbose "Strip `" (double quote). Pull path from config file adds double quotes everywhere"
    $sourceFile                     = (Join-Path -Path $config.employeeFilepath -ChildPath $config.employeeSourceFilename) -replace '"',""
    $additionalPhoneNumbersFile     = (Join-Path -Path $config.employeeFilepath -ChildPath $config.additionalPhoneNumbers) -replace '"',""
    $dialMyCsv                      = (Join-Path -Path $config.employeeFilepath -ChildPath $config.dialMyCsv) -replace '"',""
    $activeDirectoryCsv             = (Join-Path -Path $config.employeeFilepath -ChildPath $config.activeDirectoryCsv) -replace '"',""
    $azureDirectoryCsv              = (Join-Path -Path $config.employeeFilepath -ChildPath $config.azureDirectoryCsv) -replace '"',""
    $validateCsv                    = (Join-Path -Path $config.employeeFilepath -ChildPath $config.validateCsv) -replace '"',""
    $org2                           = ($config.organization2) -replace '"',""
    $sourceFileHeader               = ($config.sourceFileHeader) -replace '"',""

    $emailConfig =  Get-fnEmailConfig

    $email = @{
        Smtp            = ($emailConfig.smtp) -replace '"',""
        To              = ($emailConfig.helpdesk) -replace '"',""
        From            = ($emailConfig.myEmail) -replace '"',""
        Sig             = ($emailConfig.mySig) -replace '"',""
        Subject         = ($emailConfig.proserviceSubject) -replace '"',""
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

$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\Export-fnEmployeeToDialM_$mmddyyyy.txt" -Append
Export-fnEmployeeToDialMy  -Verbose -InformationAction Continue
Stop-Transcript
