function Export-fnGroupedObjectToSeparateCsv {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$groupObject,
        [parameter()]
        [string]$destination
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): Created CSV file for each group"
    Write-Information "$($MyInvocation.MyCommand.Name): Removing old files from $destination."
    Remove-Item -Path (Join-Path -Path $destination -ChildPath "*") -Force
    try{
        foreach($object in $groupObject){
            $filename = "$((($object.Name -replace ", ", "_") -replace " ","-") -replace "/","_")_$($object.count)_open.csv"
            $filepath = (Join-Path -Path $destination -ChildPath $filename) -replace '"',""
            
            Write-Information "$($MyInvocation.MyCommand.Name): Creating file $filepath"
            ($object.Group) | Select-Object Name,AthenaPID,`DocumentID,PerformDate,Bucket,OrderProvider,Order,CurrentStatus,`
                                @{Name="ServiceProvider"; Expression={Convert-fnExternalServiceProvider -serviceProvider $_."sendto provdr"}}`
                                | Export-csv -Path $filepath -NoTypeInformation
        }
    }catch{
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
}