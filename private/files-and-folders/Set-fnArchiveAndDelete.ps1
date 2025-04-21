function fnLocal_ArchiveAndDelete($folder){
    $zipName = $folder + ".zip"

    try {
        Compress-Archive -Path $folder -DestinationPath  $zipName
        Remove-Item -Path $folder -Recurse -Force
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name): failed zip and delete $folder"
    }
}
function Set-fnArchiveAndDelete {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$source
        
        )
        Write-Verbose "$($MyInvocation.MyCommand.Name): zip files - last month or older. $source"
        $today_year = Get-Date -Format yyyy 
        $today_month = Get-Date -Format MM

        Get-ChildItem -Directory -Path $source | ForEach-Object {
            write-host $_.Name $today_year

            
            if($_.Name -as [int] -lt $today_year -as [int]){
                Write-Information "Year ready for zip $($_.FullName)"
                fnLocal_ArchiveAndDelete -folder $_.FullName
                
            } else {
                Write-Information "$($_.Name) Year not ready to archive, check month."

                $yearFolder = $source + $_.Name
                Write-Host $yearFolder


                Get-ChildItem -Directory $yearFolder | ForEach-Object {
                    $month = ($_.Name.Split("."))[1]
                    write-host $_.Name $today_month $month

                    if($month -as [int] -lt $today_month -as [int] -or $_.Name -as [int] -lt $today_year -as [int]){
                        Write-Information "Month ready for zip $($_.Name)"
                        fnLocal_ArchiveAndDelete -folder $_.FullName
                    }
                    else {Write-Information "$($_.Name) not ready to archive"}
                }
            }

        }
}