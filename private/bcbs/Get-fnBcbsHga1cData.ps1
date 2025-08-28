function Get-fnBcbsHga1cData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on a1c data"

    foreach($bcbs in $bcbsData){
        # find equivalent emr id
        $emrId = (Invoke-fnGetEmrIdFromBcbsId -BcbsId $bcbs.'HMSA MbrUID').AthenaPid
        if([string]::IsNullOrEmpty($emrId)){ 
            $bcbs.'Medical Record' = "no-patient-match"
            continue
        }
        #set emr id
        $bcbs.'Medical Record'  = $emrId

        # find data for that emr id
        $emr = $emrData | Where-Object {$_.MRN -eq $emrId}
        if([string]::IsNullOrEmpty($emr.MRN)){
            continue 
        }

        # set gaps dates & values  
        $bcbs.'Date of Service' = if($emr.'A1c Date Dt') {($emr.'A1c Date Dt').ToString("MM/dd/yyyy")}
        $a1c = if($emr.'A1c or GMI Result') {($emr.'A1c or GMI Result')}
        $bcbs.'HbA1c or GMI Value' = $a1c
    }
    return $bcbsData
}