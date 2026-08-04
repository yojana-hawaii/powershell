function Export-fnPeerReviewFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )
    Write-Information "$($MyInvocation.MyCommand.Name): using ImportExcel library, export file with one provider per worksheet"  

    $providerGroup = $hash.RandomVisits | Group-Object -Property "Provider"

    # one file with sheets per provider
    # $file = "$($hash.QuarterYear)-Q$($hash.QuarterNumber)-peer-review.xlsx"
    # $hash.ExportPath = Join-Path -Path $hash.ExportPath -ChildPath $file

    # foreach($provider in $providerGroup){
    #     $provider.Group | Export-Excel -Path  $hash.ExportPath -WorksheetName "$($provider.Name.ToLower())" -AutoSize
    # }

    # One file per provider
    foreach($provider in $providerGroup){
        $file = "$($hash.QuarterYear)-Q$($hash.QuarterNumber) $($provider.Name.ToLower()).xlsx"
        $path = Join-Path -Path $hash.ExportPath -ChildPath $file
        $provider.Group | Export-Excel -Path  $path -AutoSize
    }

}