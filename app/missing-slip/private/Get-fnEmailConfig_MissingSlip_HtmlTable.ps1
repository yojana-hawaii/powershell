function Get-fnEmailConfig_MissingSlip_HtmlTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$missingSlips
    )
    Write-Verbose "Create html table with patient information"
    $htmltag = "
    <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Patient Name</b></th>
            <th align=left><b>Patient ID</b></th>
            <th align=left><b>Date of Service</b></th>
        </tr>
    "

    $table = ""
    foreach($row in $missingSlips){
        $table += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td>" + $row."Patient Name" + "</td>
            <td>" + $row."Patient ID" + "</td>
            <td>" + $row."Date Of Service" + "</td>
        </tr>
        "
    }

    $HtmlTable += "$htmltag $table </table>"

    return $HtmlTable
}