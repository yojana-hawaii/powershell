function Get-fnEmailConfig_MissingLatestData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for order summary email."

    $email.to = $email.orderTo
    $email.cc = $email.orderCC
    $email.subject = $email.orderSubject   

    
    $email.bodyhtml = "<h3>Order data is older than 7 days. Script run on Monday's at 9 AM. Step to download latest data </h3>
        <ul>
            <li>Go to Athena Report Inbox</li>
            <li>Download 5 report and save it to $($orderHash.rawFolder)</li>
            <ol>
                <li>NCQA-Imaging-Incomplete</li>
                <li>NCQA-Lab-Incomplete</li>
                <li>NCQA-Consult-Incomplete</li>
                <li>all-incomplete-order-v1</li>
                <li>all-incomplete-order-v2</li>
            </ol>
            <li>Saved file name should be exact match.</li>
        </ul>
    "

    $email.body = $email.bodyintro + $email.bodyhtml + $email.bodysig 
}