function Update-fnEmrData {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$FilePath,
        [parameter()]
        [int]$validDays
    )
    
    $isValid = Test-fnSourceFile -sourceFile $FilePath -sourceFileValidDays $validDays
    if($isValid){
        Write-Verbose "EMR file is recent"
        $data = Import-Csv -Path $FilePath

        foreach($row in $data){
            Invoke-fnImportEmrDemographics -demographics $row
        }
    } else {
        # $sendEmail = $true
        Write-Warning "emr file is more than $validDays days old."
    }

}