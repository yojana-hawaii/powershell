function Read-fnCsvDefaultHeader {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$filename    
    )

    Write-Information "$($MyInvocation.MyCommand.Name): Reading csv file $filename"

    if (Test-Path -Path $filename){
        try {
            $csvData = import-csv -Path $filename -Delimiter "," | Where-Object {$null -eq $_.PSOject.Properyties.Value}
        } catch {
            Write-Verbose "Import CSV file failed: $($_.Exception.Message)"
        }
    } else {
        Write-Verbose "Source file cannot be found: $($_.Exception.Message)"
    } 

   $csvData
}
