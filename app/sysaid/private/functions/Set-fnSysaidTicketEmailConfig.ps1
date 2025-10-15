function Set-fnSysaidTicketEmailConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$groupedTicket,
        [hashtable]$email,
        [string]$str
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $email.to = if($str -eq "unassigned"){$email.helpdesk}else{"$str@$($email.domain)"}
    $email.to = if($email.to -eq $email.me){$email.helpdesk}else{$email.to}
    $email.to = if($str -eq $email.sysaidemailtoboss){"$($email.to);$($email.bossEmail)"}else{$email.to}
    $email.to = $email.to -split ";"
    $email.cc = $email.me

    $email.subject = "$($email.sysaid2subject) $str"
    $email.sysaid2body1 = "$($email.sysaid2body1) $str</p>"

    foreach($ticketStatus in $groupedTicket){
        $htmltable = Get-fnSysaidTicketHtmlTable -hash $ticketStatus.group
        $email.bodyhtml += "<p><h3><u>$($ticketStatus.count) $($ticketStatus.status.ToUpper()) tickets</h3></u></p> $htmltable "
    }

    $email.body = $email.bodyintro + $email.sysaid2body1 + $email.bodyhtml + $email.bodysig
    write-host "From: $($email.from) To: $($email.to) Cc: $($email.cc) Subject:$($email.Subject) "

}

function fnLocal_SetEmailBody{
    param(
        [Parameter()]
        [array]$ticketHashArray
    )

    

    $email.Body = $email.Body0 + $email.Body1 + $email.Body2 + $email.Body3 + $email.Body4
    return $email
} 