function Get-fnSysaidTicketHtmlTable {
    param(
        [parameter()]
        [System.Object]$hash
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): convert object to html table"

    $HtmlTable = "
    <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Ticket#</b></th>
            <th align=left><b>Category</b></th>
            <th align=left><b>Subject</b></th>
            <th align=left><b>Request User</b></th>
            <th align=left><b>Request Date</b></th>
            <th align=left><b>Updates Last Week</b></th>
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
            <td>" + $($row."updates-last-week") + "</td>
            <td>" + $($row."total-updates") + "</td>
            <td>" + $($row."last-update") + "</td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    # write-host $HtmlTable

    return $htmltable
}