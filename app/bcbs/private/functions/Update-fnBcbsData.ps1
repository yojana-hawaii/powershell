function Update-fnBcbsData {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$FilePath,
        [parameter()]
        [int]$validDays
    )
    
    $isValid = Test-fnSourceFile -sourceFile $FilePath -sourceFileValidDays $validDays
    if($isValid){
        Write-Verbose "BCBS file is recent"
        $data = Import-Excel -Path $FilePath -WorksheetName "All Data"

        foreach($row in $data){
            Invoke-fnImportBcbsDemographics -demographics $row
        }
    } else {
        Write-Warning "bcbs file is more than $validDays days old."
    }
}