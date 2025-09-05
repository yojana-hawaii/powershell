function Update-fnInvalidSource {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$email,
        [parameter()]
        [string]$type,
        [parameter()]
        [string]$sourceFile
    )
    
    Write-Information "$($MyInvocation.MyCommand.Name): Source file for $type not valid."
    $fileToDownload = (Split-Path $sourceFile -Leaf) -replace ".csv", ""
    $email.emailBody3 += "$type (save as $fileToDownload), "
    $email.emailBody3a = "$(Split-Path $sourceFile -Parent)"
}