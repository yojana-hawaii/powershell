function Move-fnFilesIntoYearMonthDayFolders {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$source,
        [string]$extension,
        [string]$filePrefix = 'all'
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): move file to yyyy\yyyy.mm\yyyy.mm.dd\ folder structure"

    $filename  = "*"
    if($filePrefix -ne "all") {$filename = $filePrefix + "*"}
    $fileType = $source + $filename + $extension
    write-host $fileType
    
    Get-ChildItem $fileType | Foreach-Object {
        $soureFileNew = Test-fnSourceFile -sourceFile $_.FullName -sourceFileValidDays 1
        
        # build destination path
        $lastChange = $_.LastWriteTime.ToShortDateString()
        $fileYear = Get-Date $lastChange -Format yyyy
        $fileMonth = Get-Date $lastChange -Format MM
        $fileDate = Get-Date $lastChange -Format yyyy.MM.dd
        $destination = $source + $fileYear + "\" + $fileYear + "." + $fileMonth + "\" + $fileDate
        Write-Information "$($MyInvocation.MyCommand.Name): Move to folder $destination"

        # create folder if it does not exist
        if( -not (Test-Path $destination)){
            New-Item -ItemType Directory -Path $destination
            Write-Information "Directory $destination created."
        } else {
            Write-Information "Directory $destination already exists."
        }

        # move file if it is more than a day old
        try {
            if(-not $soureFileNew){
                Write-Verbose "move $($_.FullName) to $destination last updated $($_.LastWriteTime)"
                Move-Item $_.Fullname $destination
            }
        } catch [System.IO.IOException]{
            Write-Warning "$($MyInvocation.MyCommand.Name): $($_.FullName) in use. Cannot move"
        }
        catch {
            Write-Warning "$($MyInvocation.MyCommand.Name): Error moving, $($_.Exception.Message)"
        }
        
    }

}