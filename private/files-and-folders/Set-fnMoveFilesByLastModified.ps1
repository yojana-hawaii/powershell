function Set-fnMoveFilesByLastModified {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$source,
        [parameter()]
        [string]$extension
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): move file to yyyy\yyyy.mm\yyyy.mm.dd\ folder structure"

    $fileType = $source + "*" + $extension
    Write-Information $fileType
    
    Get-ChildItem $fileType | Foreach-Object {
        $lastChange = $_.LastWriteTime.ToShortDateString()
        $soureFileNew = Test-fnSourceFile -sourceFile $_.FullName -sourceFileValidDays 1
        $fileYear = Get-Date $lastChange -Format yyyy
        $fileMonth = Get-Date $lastChange -Format MM
        $fileDate = Get-Date $lastChange -Format yyyy.MM.dd


        $destination = $source + $fileYear + "\" + $fileYear + "." + $fileMonth + "\" + $fileDate
        Write-Information "$($MyInvocation.MyCommand.Name): Move to folder $destination"

        if( -not (Test-Path $destination)){
            New-Item -ItemType Directory -Path $destination
            Write-Information "Directory $destination created."
        } else {
            Write-Information "Directory $destination already exists."
        }

        try {
            if(-not $soureFileNew){
                Write-Verbose "move $($_.FullName) to $destination last updated $($_.LastWriteTime)"
                Move-Item $_.Fullname $destination
            }
        }
        catch {
            Write-Warning "$($MyInvocation.MyCommand.Name): Error moving, $($finalServiceStatus.Status)"
        }
        
    }

}