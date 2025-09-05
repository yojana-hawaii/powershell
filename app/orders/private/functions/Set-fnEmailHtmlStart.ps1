function Set-fnEmailHtmlStart {
    [CmdletBinding()]
    param (
        
    )
    return  "<!DOCTYPE html PUBLIC `"-//W3C//DTD XHTML 1.0 Strict//EN`"  `"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd`"> 
    <html xmlns=`"http://www.w3.org/1999/xhtml`">
    <head> 
        <title> Incomplete Order</title>
        <meta name=`"generator`" content=`"powershell`"/>
        <style>
            table,td,th  {
                border:1px solid black;
                border-collapse:collapse
            }
            table td {
                text-align:center
            }
            table th {
                padding: 0 15px
            }
        </style>
    </head>
    <body>
        <div>"
}