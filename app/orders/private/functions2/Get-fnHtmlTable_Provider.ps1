function Get-fnHtmlTable_Provider {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$providerDetail
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): convert summary object into html table"
    # $explanation = Get-fnIncompleteOrderExplanationWordy
    $explanation = Get-fnIncompleteOrderExplanationTabular

    $fileName = Get-fnProviderFileName -provname $providerDetail.Name
    
    return "
        <h3>Summary of incomplete order for $($providerDetail.Name)</h3>
        <p>$($email.supportStaffFilepath) > $fileName </p>
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
            $explanation
        </p>
    "
}