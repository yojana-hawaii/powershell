function Get-fnSupportStaffEmail {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$provider,
        [PSCustomObject]$supportStaffList
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): set email config for individual email."

    $prov = $provider -split ","
    $currentProvFirst = ($prov[1].Trim()).Replace(" ","-")
    $currentProvLast = ($prov[0].Trim()).Replace(" ","-")

    $supportStaffEmail = $null
    foreach($staff in $supportStaffList){
        # some people have space in first or last name
        $availableProviderFirst = ($staff.provider_first).Replace(" ","-")
        $availablePRoviderLast =  ($staff.provider_last).Replace(" ","-")

        if($currentProvFirst -eq $availableProviderFirst -and $currentProvLast -eq $availablePRoviderLast ){
            $supportStaffEmail = $staff.Staff_email
            break
        }
    }
    return $supportStaffEmail
}