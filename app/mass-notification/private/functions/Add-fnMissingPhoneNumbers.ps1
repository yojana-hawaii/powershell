function Add-fnMissingPhoneNumbers {
    [CmdletBinding()]
    param(
        [Parameter()]
        [PSCustomObject]$employees,
        [Parameter()]
        [string]$additionalPhoneNumbersFile
    )
    Write-Verbose "Adding additional phone numbers missing in original csv file"

    if (Test-Path -Path $additionalPhoneNumbersFile){
        Write-Verbose "Test File path: File exists"
        try {
            $additionalPhoneNumber = Import-Csv -Path $additionalPhoneNumbersFile   -Delimiter ","
            Write-Verbose "Successfully imported additional phone csv file"
        } catch {
            Write-Warning "Import CSV file failed: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Source file cannot be found: $($_.Exception.Message)"
    } 

    foreach ($employee in $employees | Where-Object {$_.cellPhone -eq ''} ){
        
        $employee.cellPhone = ($additionalPhoneNumber | Where-Object {$_.first -eq $employee.first -and $_.last -eq $employee.last }).phone
    }
    return $employees    
}