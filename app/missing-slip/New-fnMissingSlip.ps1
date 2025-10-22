set-location "\\fileserver\it\apps\powershell"

function fnLocal_GetProviderEmailAndSpecialty{
    [CmdletBinding()]
    param($name)
    $prov = $name.split(',')
    $last = $prov[0].trim()
    $first = $prov[1].trim()
    $email = ""
    
    $details = Invoke-spGetUserEmail -firstName $first -lastName $last
    $email = $details.EmailAddress
    $BH = $details.BH

    # foreach($provider in $directoryList){
    #     if($provider.FirstName -eq $first){
    #         if($provider.LastName -eq $last){
    #             $email = $provider.Email
    #             $bh = $provider.BH
    #             break
    #         }
    #     }
    # }

    Write-Verbose "Email for provider $name found : $email, BH: $BH"

    return @($email, $bh)
}

function fnLocal_GetEmailBody($provList, $encounterCount, $htmltable){

    
    $oldest = $provList | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -First 1
    $newest = $provList | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -Last 1

    $BODY = "
                <br><br>
            Hello, This is an automated email. $encounterCount visits between $oldest and $newest are incomplete, missing e&m code or diagnosis. Billing, IT and clinical team are included in the email to support in anyway. Thank you.
            <br><br>
            " + $htmltable

    return $BODY
}
function fnLocal_GetHtmlTable{
    [CmdletBinding()]
    param($providerList)
    Write-Verbose "Create html table with patient information"
    $HtmlTable = "
    <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Patient Name</b></th>
            <th align=left><b>Patient ID</b></th>
            <th align=left><b>Date of Service</b></th>
        </tr>
    "

    foreach($row in $providerList){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td>" + $row."Patient Name" + "</td>
            <td>" + $row."Patient ID" + "</td>
            <td>" + $row."Date Of Service" + "</td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    return $HtmlTable
}
function New-fnMissingSlip {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\missing-slip\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
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
    Remove-Variable import, utility, private, sqlConn, config, emailConf

    #endregion
    
    $startTimer = Start-Timer

    Write-Verbose "$($MyInvocation.MyCommand.Name): start."

    #region Initialize Config
    $config = Get-fnMissingSlipConfig 
    $emailConfig = Get-fnEmailConfig

    $smtp            = ($emailConfig.smtp) -replace '"',""
    $from            = ($emailConfig.missingSlipFrom) -replace '"',""
    $to              = ""
    $med_cc          = (($emailConfig.missingSlipCc) -replace '"',"").Split(';')
    $BH_CC           = (($emailConfig.missingSlipCcBh) -replace '"',"").Split(';')
    $me              = ($emailConfig.myEmail) -replace '"',""

    
    $source = "$($config.missingSlipSource)"  -replace '"',""
    #endregion
    
    $sourceValid = Test-fnSourceFile -sourceFile $source -sourceFileValidDays 1

    if($sourceValid){
        $data = Import-Excel $source
        $groupByProvider = $data | Group-Object Provider

        foreach($prov in $groupByProvider){
            $encounterCount = $prov.Count
            $ProviderName = $prov.Name
            $provList = $prov.Group

            $temp = fnLocal_GetProviderEmailAndSpecialty -name $ProviderName
            $to = $temp[0]
            $bh = $temp[1]

            if($to -eq '') {$to = $me; $SUBJECT = "Cannot find Provider. $SUBJECT"; $cc=$me}

            if($bh -eq 1){
                $CC = $BH_CC
            }else {
                $CC = $med_cc
            }

          
            $htmltable = fnLocal_GetHtmlTable -providerList $provList
            $SUBJECT = $ProviderName + " - " + $encounterCount + " open encounters"
            
            $BODY = fnLocal_GetEmailBody -provList $provList -encounterCount $encounterCount -htmltable $htmltable
            Write-Verbose "$smtp , From: $from, To: $to, CC: $cc, Valid: $sourceValid"
            
            Write-Information "Subject: $SUBJECT"
            Write-Information "BODY: $BODY"
            Send-MailMessage -smtpserver $SMTP -from $FROM -to $to -cc $cc -subject $SUBJECT -body $BODY -bodyashtml
        }
    } else {
        Write-Warning "Missing slip file too old"
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Missing slip email sent. It took $totalTime"    
}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnMissingSlip -Verbose -InformationAction continue
Stop-Transcript