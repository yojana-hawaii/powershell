function Get-fnSysaidSummaryHtmlTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$arr
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): convert array to html table"


    $HtmlTable = "
        <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
            <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
                <th align=left><b>Team</b></th>
                <th align=left><b>Open</b></th>
                <th align=left><b>On-hold IT</b></th>
                <th align=left><b>On-hold Staff</b></th>
                <th align=left><b>On-hold Vendor</b></th>
                <th align=left><b>Closed</b></th>
            </tr>
    "

    foreach($row in $arr){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td>" + $($row.Admin) + "</td>
            <td align=center>" + $($row.open) + "</td>
            <td align=center>" + $($row.'on-hold-it') + "</td>
            <td align=center>" + $($row.'on-hold-staff') + "</td>
            <td align=center>" + $($row.'on-hold-vendor') + "</td>
            <td align=center>" + $($row."closed") + "</td>
            </tr>
        "
    }

    $HtmlTable += "</table>"

    # write-host $HtmlTable
    return $htmltable
}