function Set-fnEmailBodyOrder {
    [CmdletBinding()]
    param (
        [parameter()]
        [system.object]$email,
        [parameter()]
        [System.Object]$order
    )

    Write-Information "$($MyInvocation.MyCommand.Name): Setting email body"
    $email.Subject = "Incomplete labs, consults & imaging."

    #Greetings
    $email.emailBody1 = "Hello all, This is an automated email for incomplete labs, consults & imaging. Designated support staff get separate automated email with list of incomplete labs for providers they work with."

    # Do Nothing
    $email.emailbody2 = " $(if ($email.emailbody2.length -ge 1){
        "<p><strong>Source File Good</strong>: $($email.emailBody2.substring(0, $email.emailBody2.length-1)) file was generenated within last 7 days.</p>"
    })"

    # Download source file & source file unc in 3a
    $email.emailbody3 = "$(if ($email.emailBody3.length -ge 1){
        "<p><strong>Data older than 7 days: </strong>From Athena Report Inbox, please download new report for $($email.emailBody3.substring(0, $email.emailBody3.length-2)). 
        Save the file to $($email.emailBody3a). Replace existing file.</p>"
    })"

    

    if ($null -ne $email.emailBody4 -and $email.emailBody3.length -le 0){
        
        # file location
        $email.emailBody4 = "<p><strong>File Location</strong>
                        <ul>
                            $(foreach($loc in $email.emailBody4.GetEnumerator()){
                                "<li>$($loc.key) - $($loc.value)</li>"
                            })
                        </ul>
                    </p>"
    
        
        # array of array into html table
        $email.emailBody5 = "<p><strong>Summary of Incomplete Order</strong>
                   $($email.emailBody5 | ConvertTo-Html -Fragment)
                </p>"
        
        # applied filters for transparency      
        $email.emailBody6 = "<p><strong>Applied Filters</strong>
                <ul>
                    <li>Closed orders are not included</li>
                    <li>Deleted orders are not included</li>
                    <li>Orders waiting to be deleted in DeleteDocument bucket are in separate file.</li>
                    <li>Following criteria must be met to be included in  this list 
                        <ul>
                            <li>Consult result not back 42 days after ordering.</li>
                            <li>Imaging result not back 30 days after ordering.</li>
                            <li>Lab result not back 7 days after ordering.</li>
                            <li>Lab in FutureLab bucket (patient no show but still valid) waiting for 90 days of perform date.</li>
                        </ul>
                    </li>
                    <li>Order performed in-house (best guess looking at Athena setup)
                        <ul>
                            $(foreach($loc in $email.emailBody6.GetEnumerator()){
                                "<li>$($loc.key) - $($loc.value)</li>"
                            })
                        </ul>
                    </li>
                <ul>
            </p>"
    } else {
        $email.emailbody4 = ""
        $email.emailbody5 = ""
        $email.emailbody6 = ""
    }
}