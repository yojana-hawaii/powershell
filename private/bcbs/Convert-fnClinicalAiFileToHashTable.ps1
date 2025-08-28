function Convert-fnClinicalAiFileToHashTable {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$ClinicalAiPath
    )
    
    $files = Get-ChildItem -Path $ClinicalAiPath |
        Where-Object {$_.Extension -eq ".xlsx"} | 
        Select-Object FullName, Name
    
    $hashTable = @{}
    foreach($file in $files){
        $allfiles =  (($file.Name -replace ".xlsx", "") -split "and").Trim()
        foreach($onefile in $allfiles){
            $hashTable.Add($onefile, $file.Fullname)
        }
    }
    return $hashTable
}