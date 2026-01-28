function Get-fnProviderEmailAndSpecialty {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$name
    )

    $prov = $name.split(',')
    $last = $prov[0].trim()
    $first = $prov[1].trim()
    $email = ""
    
    $details = Invoke-spGetUserEmail -firstName $first -lastName $last
    $email = $details.EmailAddress
    $BH = $details.BH

    Write-Verbose "Email for provider $name found : $email, BH: $BH"

    return @($email, $bh)
}
