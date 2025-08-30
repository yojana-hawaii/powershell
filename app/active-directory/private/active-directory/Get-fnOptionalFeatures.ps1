function Get-fnOptionalFeatures {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Optional Features"
        return @(
        foreach($feature in Get-ADOptionalFeature -Filter *){
            $feature.Name
        }
    )
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }
}

# Get-fnOptionalFeatures -Verbose