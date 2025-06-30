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

        Body0 = "<p>Confirming before sending to $ceo. Recommended changes implemented. Start with old summary table.</p>"

        Body1 = "<p>This is an automated email blah blah.</p>"

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
    [CmdletBinding()]
    param (
        
    )

    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1" -ErrorAction SilentlyContinue -Recurse)
    $emailConfig       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnEmailConfig.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\sysaid\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\sysaid\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($configHelper + $emailConfig + $utility + $sqlConection + $storedProcedure + $private)){
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

    $emailConfig =  Get-fnEmailConfig
    $smtp            = ($emailConfig.smtp) -replace '"',""
    $to              = ""
    $me              = ($emailConfig.myEmail) -replace '"',""
    $helpdesk        = (($emailConfig.helpdesk) -replace '"',"") -replace "'", ""
    $domain        = ($emailConfig.domain) -replace '"',""
    $sig        = ($emailConfig.mySig) -replace '"',""
    $ceo       = ($emailConfig.ceo) -replace '"',""
 
    Write-Information $sig $ceo

    $days = -7
    $admins = (Invoke-spGetAdmins -days $days).AssignedTo
    foreach($admin in $admins){
        $to = if($admin -eq "unassigned"){$helpdesk}else{"$admin@$domain"}
        $to = if($to -eq $me){$helpdesk}else{$to}
        $cc = $me
        $from = $me

        $adminTickets = Get-fnOrganizeTickets -days $days -admin $admin
        $email = fnLocal_SetEmailBody -ticketHashArray $adminTickets

        Send-MailMessage -From $from -To $to -Cc $cc -Subject $email.Subject -Body $email.Body -SmtpServer $smtp -BodyAsHtml
    }
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}
 

$Global:today = $null
$today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
New-fnITProductivityReport -InformationAction Continue -verbose
Stop-Transcript
