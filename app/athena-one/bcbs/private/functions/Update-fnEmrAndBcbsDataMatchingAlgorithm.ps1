function Update-fnEmrAndBcbsDataMatchingAlgorithm {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$bcbsFile,
        [string]$emrFile
    )
    $validDays = 14
    Update-fnEmrData -FilePath $emrFile -validDays $validDays   # refresh emr warehouse data if download file is recent 
    Update-fnBcbsData -FilePath $bcbsFile -validDays $validDays # refresh bcbs warehouse data if download file is recent
    Invoke-fnDemographicsMatchingAlgorithm                      # run match demographic match between bcbs and emr
}