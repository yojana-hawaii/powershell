function Save-fnGapsDataToBcbsFile {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$bcbsSheet,
        [System.Object]$result,
        [string]$FilePath
    )
    try{
        if($result){
            $excel = $result | Export-Excel -Path $FilePath -WorksheetName $bcbsSheet -PassThru
            $excel.Save()
            $excel.Dispose()
            Write-Verbose "$($MyInvocation.MyCommand.Name): Save $($bcbsSheet) sheet in $FilePath"
        }
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }
}