function Get-fnQualifiyingVisits {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )
    Write-Information "$($MyInvocation.MyCommand.Name): filter by last quarter, select visit types, uds visits, non test & with encounter id "  
    
    #try cath when there is possibility of exception -> read file from network drive
    try {
        $raw = Import-fnSourceFile -sourceFile $hash.udsInclusion -sourceFileValidDays $hash.sourceFileValidDays
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

    $hash.QualifyingVisits = $raw |
        Where-Object {
            $_.Visit_Date -ge $hash.QuarterStart -and 
            $_.Visit_Date -le $hash.QuarterEnd -and 
            $_.Visit_Type -in @("Medical","Vision","MentalHealth") -and
            $_.Is_Uds -eq "Y" -and
            $_.Patient_Name -notlike "test*" -and
            $_.EncounterId -ne "" #chartspan would not have an encounter. Only claim. CPT in @("G0511","99490","99439") Before and after oct 2025
        } | 
        Select-Object  @{
            label="Specialty"
            expression={$_.Provider_Specialty}
        }, @{
            label="Provider"
            expression={$Name = ($_.Provider_Name) -split ","; return "$($name[1]) $($name[0])"}
        }, @{
            label="PID"
            expression={$_.PatientID}
        }, @{
            label="Visit Date"
            expression={$_.Visit_Date}
        }, @{
            label="Uds Qualifying Cpt"
            expression={$_.Qualifying_CPTS}
        }

    return
}