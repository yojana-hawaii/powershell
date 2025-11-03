function Get-fnStepByStepProcess {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [hashtable]$orderHash
    )
    return "<p><h3>Process:</h3>
        <ol> 
            <li> Identify internal consult - $($orderHash.internalConsult) </li>
            <li> Identify internal imaging - $($orderHash.internalImaging) </li>
            <li> Separate orders waiting to be deleted</li>
            <li> Separate expired orders - 180 days for lab and imaging. 365 days for rest</li>
            <li> Separate orders nnot time to follow up yet</li>
            <li> Separate followed up within last 2 weeks</li>
            <li> Export Summary by Provider, Year & Department</li>
            <li> Export orders with admin action needed</li>
            <li> Export order per provider</li>
            <li> Email summary - randomly pick by year, provider or department every week</li>
            <li> Email support staff assigned to provider - $($orderHash.supportStaff)</li>
        </ol>
    </p>"
}