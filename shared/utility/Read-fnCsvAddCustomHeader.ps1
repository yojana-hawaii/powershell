function Read-fnCsvAddCustomHeader {
    [CmdletBinding()]
    param(
        [parameter()]
        [string]$csvFile,
        [parameter()]
        [array]$csvHeader
    )

    Write-Verbose "Reading csv file and assigning layman header"

    if (Test-Path -Path $csvFile){
        Write-Verbose "Test File path: File exists"
        try {
            $employees = Import-Csv -Path $csvFile  -Header $csvHeader  -Delimiter "," |
                            Where-Object { $_.PSObject.Properties.Value -ne '' } |
                            Select-Object first, last, hrEmail, cellPhone, manager,location, department, jobtitle,staffEmail,managerEmail,orgGroup,dialGroup
            }
            catch {
                Write-Warning "Import CSV file failed: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "Source file cannot be found: $($_.Exception.Message)"
        } 

    return $employees
}