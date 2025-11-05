function Get-fnHtmlTable_Provider {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$providerDetail
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): convert summary object into html table"
    $wordy = "<p><b>Consult</b>
            <ul>
                <li>Excludes consult within 42 days of order. Shows up in this list after 42 days if the result is not received.</li>
                <li>Excludes expired consult. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Lab</b>
            <ul>
                <li>Excludes lab within 7 days of order. Shows up in this list after 7 days if the result is not received.</li>
                <li>Excludes expired labs. 180 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Imaging</b>
            <ul>
                <li>Excludes imaging within 30 days of order. Shows up in this list after 30 days if the result is not received.</li>
                <li>Excludes expired imaging. 180 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Procedures</b>
            <ul>
                <li>Excludes procedures within 14 days of order. Shows up in this list after 14 days if the result is not received.</li>
                <li>Excludes expired procedures. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Other</b>
            <ul>
                <li>Excludes 'other' orders within 7 days of order. Shows up in this list after 7 days if the result is not received.</li>
                <li>Excludes expired 'other' orders. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p>"

    $table = "<table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
            <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
                <th align=left><b>Order Type</b></th>
                <th align=left><b>Follow Up Alarm</b></th>
                <th align=left><b>Order Expiration</b></th>
                <th align=left><b>Patient contact</b></th>
            </tr>
            <tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
                <td align=center>Consult</td>
                <td align=center>42 days</td>
                <td align=center>365 days</td>
                <td align=center>14 days</td>
            </tr>

            <tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
                <td align=center>Lab</td>
                <td align=center>7 days</td>
                <td align=center>180 days</td>
                <td align=center>14 days</td>
            </tr>

            <tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
                <td align=center>Imaging</td>
                <td align=center>30 days</td>
                <td align=center>180 days</td>
                <td align=center>14 days</td>
            </tr>

            <tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
                <td align=center>Procedure</td>
                <td align=center>14 days</td>
                <td align=center>365 days</td>
                <td align=center>14 days</td>
            </tr>

            <tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
                <td align=center>Other</td>
                <td align=center>7 days</td>
                <td align=center>365 days</td>
                <td align=center>14 days</td>
            </tr>
            </table>
            
            <p>P.S. Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</p>"

    Write-Host $table
    
    return "
        <h3>Summary of incomplete order for $($providerDetail.Name)</h3>
        <p>$($providerDetail.FilePath)</p>
        <ul>
            <li>Consult: $($providerDetail.Consult.Count)</li>
            <li>Internal-Consult: $($providerDetail.'Internal-Consult'.Count)</li>
            <li>Lab: $($providerDetail.Lab.Count)</li>
            <li>Imaging: $($providerDetail.Imaging.Count)</li>
            <li>Internal-Imaging: $($providerDetail.'Internal-Imaging'.Count)</li>
            <li>Procedure: $($providerDetail.Procedure.Count)</li>
            <li>Other: $($providerDetail.Other.Count)</li>
            <li>Total: $($providerDetail.Total)</li>
        </ul>
        
        <p><h3>Open orders pending follow up. Criteria.</h3>
            $wordy
        </p>
    "
}