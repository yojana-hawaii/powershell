function Get-fnEmailConfig_MissingSlip {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$email,
        [Microsoft.PowerShell.Commands.GroupInfo]$providerDetails
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    
    $encounterCount = $providerDetails.Count
    $ProviderName = $providerDetails.Name
    $missingSlips = $providerDetails.Group
    
    
    $temp = Get-fnProviderEmailAndSpecialty -name $ProviderName
    $providerEmail = $temp[0]
    $bh = $temp[1]
    

    $email.From = $email.missingSlipFrom
    $email.To = $providerEmail
    $email.Subject = $ProviderName + " - " + $encounterCount + " open encounters"


    $missingEmail =""
    if($providerEmail -eq '' -or $null -eq $providerEmail) {
        $email.To = $email.me
        $email.Subject = "Cannot find Provider email. $($email.subject)"; 
        $email.cc = $email.me
        $missingEmail = "Possibly name mismatch, could not find email."
    }

    if($bh -eq 1){
        $email.cc = $email.missingSlipCcBh
    }else {
        $email.cc = $email.missingSlipCc
    }

    $email.bodyhtml = Get-fnEmailConfig_MissingSlip_HtmlTable -missingSlips $missingSlips

    $oldest = $missingSlips | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -First 1
    $newest = $missingSlips | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -Last 1

    $x = if($oldest -ne $newest) 
    {
        "between $oldest and $newest"
    } else {
        "from $oldest"
    }
    
    $explainTable = "<p>$encounterCount incomplete encounter(s) $x; possibly missing e&m code, missing procedure code, missing diagnosis. Billing, IT and Clinical team are included in the email for an questions</p>"
    $email.body = $email.bodyintro + $missingEmail + $explainTable + $email.bodyhtml + $email.bodysig
    
}