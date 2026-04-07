function Get-fnIncompleteOrderExplanationTabular {
    return "<table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
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

}