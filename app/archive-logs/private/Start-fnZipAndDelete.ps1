function Start-fnZipAndDelete {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$path,
        [string]$daysToWait
    )

    $datetime = (Get-Date).AddDays(-$daysToWait)
    $date = Get-Date $datetime -Format MM-dd-yyyy
    Write-Verbose "$($MyInvocation.MyCommand.Name): Zip and Delete files older that $date from $path"

    $folders = Get-ChildItem -Path $path -Directory -Recurse | Where-Object {$_.LastWriteTime -lt $datetime}
    
    for($reverse = $folders.Length - 1; $reverse -ge 0; $reverse--){
        write-host $folders[$reverse]

        # file path
        $folder = $folders[$reverse].FullName

        # zip name
        $folderName = (($folders[$reverse]).ToString()) -replace "\.", ""
        $zipName = $folderName + ".zip"
        $zipParent = Split-Path -Path $folder -Parent
        $zipPath = Join-Path -Path $zipParent -ChildPath $zipName

        try {
            $archiveContent = Get-ChildItem -Path $folder
            $batchCount = 9 
            for($i=0; $i -le $archiveContent.count; $i = $i+$batchCount+1){
                Compress-Archive -Path $archiveContent[$i .. ($i+$batchCount)].FullName -DestinationPath  $zipPath -Update
                Remove-Item -Path $archiveContent[$i .. ($i+$batchCount)].FullName -Recurse -Force
            }
        }
        catch {
            Write-Warning "$($MyInvocation.MyCommand.Name): failed zip and delete $($_.Exception.Message)"
        }

    }


}