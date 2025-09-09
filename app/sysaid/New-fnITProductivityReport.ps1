set-location "\\fileserver\it\apps\powershell"

function fnLocal_ConvertToHashTable{
    param(
        [parameter()]
        [System.Object]$hash
    )

    $HtmlTable = "
    <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Ticket#</b></th>
            <th align=left><b>Category</b></th>
            <th align=left><b>Subject</b></th>
            <th align=left><b>Request User</b></th>
            <th align=left><b>Request Date</b></th>
            <th align=left><b>Total Updates</b></th>
            <th align=left><b>Last Update</b></th>
        </tr>
    "

    foreach($row in $hash){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td>" + $($row.TicketNumber) + "</td>
            <td>" + $($row.Category) + "</td>
            <td>" + $($row.Subject) + "</td>
            <td>" + $($row.RequestUser) + "</td>
            <td>" + $($row.Date) + "</td>
            <td>" + $($row."total-updates") + "</td>
            <td>" + $($row."last-update") + "</td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    # write-host $HtmlTable

    return $htmltable
}
function fnLocal_SetEmailBody{
    param(
        [Parameter()]
        [array]$ticketHashArray
    )

    $email = [PSCustomObject]@{
        Subject = "Weekly sysaid summary for $($ticketHashArray[0].Name)"

        Body0 = "<p>$ceo, This is an automated email with sysaid ticket summary for $($ticketHashArray[0].Name)</p>"

        Body1 = ""

        Body2 = ""


        Body4 = "<p>Thank you<br/>$sig</p>"
        Body = ""
    }

    foreach($hashtable in $ticketHashArray){
        $htmltable = fnLocal_ConvertToHashTable -hash $hashtable.group
        $email.Body2 += "<p><h3><u>$($hashtable.count) $($hashtable.status.ToUpper()) tickets</h3></u></p>
                        $htmltable "
    }

    $email.Body = $email.Body0 + $email.Body1 + $email.Body2 + $email.Body3 + $email.Body4
    return $email
} 
function New-fnITProductivityReport {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\sysaid\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnEmailConfig.ps1" -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $config + $emailConf)){
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
    $sysaidConf = Get-fnSysaidConfig
    $readyForCeo = ($sysaidConf.readyForCeo) -replace '"', ""

    $emailConfig =  Get-fnEmailConfig
    $smtp            = ($emailConfig.smtp) -replace '"',""
    $to              = ""
    $me              = ($emailConfig.myEmail) -replace '"',""
    $helpdesk        = (($emailConfig.helpdesk) -replace '"',"") -replace "'", ""
    $domain        = ($emailConfig.domain) -replace '"',""
    $sig        = ($emailConfig.mySig) -replace '"',""
    $ceo       = ($emailConfig.ceo) -replace '"',""
    $ceoEmail       = ($emailConfig.ceoEmail) -replace '"',""
 
    Write-Information $sig $ceo

    $days = -7
    $admins = (Invoke-spGetAdmins -days $days).AssignedTo
    foreach($admin in $admins){
        $to = if($admin -eq "unassigned"){$helpdesk}else{"$admin@$domain"}
        $to = if($to -eq $me){$helpdesk}else{$to}
        $to = if($admin -eq $readyForCeo){"$to;$ceoEmail"}else{$to}
        $cc = $me
        $from = $me
        $to = $to -split ";"

        $adminTickets = Get-fnOrganizeTickets -days $days -admin $admin
        $email = fnLocal_SetEmailBody -ticketHashArray $adminTickets

        # write-host $from $to $cc $email.Subject 
        Send-MailMessage -From $from -To $me -Cc $cc -Subject $email.Subject -Body $email.Body -SmtpServer $smtp -BodyAsHtml
    }
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnITProductivityReport -Verbose -InformationAction continue
Stop-Transcript