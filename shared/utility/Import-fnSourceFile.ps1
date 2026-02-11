function Import-fnSourceFile {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$sourceFile,
        [parameter()]
        [int]$sourceFileValidDays
    )
    $isValid = Test-fnSourceFile -sourceFile $sourceFile -sourceFileValidDays $sourceFileValidDays

    if($isValid){
        Write-Verbose "Source file is recent"
        $data = Import-Csv -Path $sourceFile
        return $data
    } else {
        throw "$sourceFile file does not exists or is more than $validDays days old."
    }

}