function Get-fnEmailConfig_HtmlTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$users
    )

    $users = $users | Select-Object Name, Type, sAMAccountName,
                @{
                    label = "LastLogin"
                    expression = {if($_.LastLogonDate -eq "" -or $null -eq $_.LastLogonDate) {"Never"} else {($_.LastLogonDate).ToString("MM-dd-yyyy")}}
                }

    $HtmlTable = "<table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Name</b></th>
            <th align=left><b>Username</b></th>
            <th align=left><b>Last Login</b></th>
            <th align=left><b>Return Date?</b></th>
            <th align=left><b></b></th>
        </tr>
    "

    foreach($row in $users){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td> $($row.Name) </td>
            <td> $($row.sAMAccountName) </td>
            <td> $($row.LastLogin) </td>
            <td> </td>
            <td> $($row.type) </td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    return $HtmlTable 
}