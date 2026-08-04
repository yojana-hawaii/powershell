function Get-fnSelectRandomVisits {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )
    Write-Information "$($MyInvocation.MyCommand.Name):  Select 5 random visits per provider"

    # group by provider
    $providerGrouping = $hash.QualifyingVisits | Group-Object -Property Provider
    $randomVisit = @()

    # select random 5 per provider
    foreach($provider in $providerGrouping){
        $cnt = 1
        for($cnt=1; $cnt -le $hash.randomVisitPerProvider; $cnt++){
            $rand = Get-Random -Minimum 1 -Maximum $provider.Count
            $randomVisit += $provider.Group[$rand]
        }
    }
    $hash.RandomVisits = $randomVisit
    return
}