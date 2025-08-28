function Add-fnGapsDataToBsbc {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$FilePath,
        [string]$ClinicalAiPath
    )
    $gapsHashtable = Convert-fnClinicalAiFileToHashTable -ClinicalAiPath $folderPath
    $bcbsSheets = Get-ExcelSheetInfo -Path $FilePath

    foreach($sheet in $bcbsSheets){
        $bcbsSheet = $sheet.Name
        $isGapsFileReady = $gapsHashtable.Keys -contains $bcbsSheet

        Write-Verbose "$($bcbsSheet) --> $isGapsFileReady)"

        if($isGapsFileReady){
            $bcbsData   = Import-Excel -Path $FilePath -WorksheetName $bcbsSheet
            $emrData    = Import-Excel -Path $gapsHashtable[$bcbsSheet] #-WorksheetName Results - dont use results sheet, use first sheet

            $result = Get-fnGapsDataFromEmrData  -bcbsData $bcbsData -emrData $emrData -bcbsSheet $bcbsSheet
            Save-fnGapsDataToBcbsFile -bcbsSheet $bcbsSheet -result $result -FilePath $FilePath
        }
    }

}