function Get-fnSummaryHtmlTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [hashtable]$orderHash
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): convert summary object into html table"

    $rnd = Get-Random -Maximum 3 -Minimum 0
    $rndArray = @($orderHash.provSummary, $orderHash.deptSummary, $orderHash.yearSummary)[$rnd]
    $random = if($rnd -eq 0) {"Provider"} elseif ($rnd -eq 1) {"Department"} else {"Year"}
    $rndArray = $rndArray | Sort-Object Name

    $HtmlTable = "<h3>Summary of incomplete order by $random</h3>
        <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
            <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
                <th align=left><b>Name</b></th>
                <th align=left><b>Consult</b></th>
                <th align=left><b>Internal-Consult</b></th>
                <th align=left><b>Lab</b></th>
                <th align=left><b>Imaging</b></th>
                <th align=left><b>Internal-Imaging</b></th>
                <th align=left><b>Procedure</b></th>
                <th align=left><b>Other</b></th>
                <th align=left><b>Total</b></th>
            </tr>
    "

    foreach($row in $rndArray){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td align=center>" + $($row.Name) + "</td>
            <td align=center>" + $($row.Consult) + "</td>
            <td align=center>" + $($row.'Internal-Consult') + "</td>
            <td align=center>" + $($row.Lab) + "</td>
            <td align=center>" + $($row.Imaging) + "</td>
            <td align=center>" + $($row.'Internal-Imaging') + "</td>
            <td align=center>" + $($row.Procedure) + "</td>
            <td align=center>" + $($row.Other) + "</td>
            <td align=center>" + $($row.Total) + "</td>
            </tr>
        "
    }

    $HtmlTable += "</table>"

    # write-host $HtmlTable
    return $htmltable

}