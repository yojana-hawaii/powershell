function Get-fnEmailConfig_HtmlTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$users
    )

    $users = $users | Select-Object Name, Type,
                @{
                    label = "LastLogin"
                    expression = {if($_.LastLogonDate -eq "" -or $null -eq $_.LastLogonDate) {"Never"} else {($_.LastLogonDate).ToString("MM-dd-yyyy")}}
                }

    $HtmlTable = "<table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Name</b></th>
            <th align=left><b>Last Login</b></th>
            <th align=left><b>Type</b></th>
        </tr>
    "

    foreach($row in $users){
        $email = if ($row.EmailAddress -eq "" -or $null -eq $row.EmailAddress) {$row.EmailAddress} else {$row.Type}

        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td> $($row.Name) </td>
            <td> $($row.LastLogin) </td>
            <td> $email </td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    return $HtmlTable 
}