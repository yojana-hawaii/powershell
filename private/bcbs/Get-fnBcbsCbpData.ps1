function Get-fnBcbsCbpData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on cbp data"

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
        $bcbs.'Date of Service' = if($emr.'Multiple BP Lowest Date') {($emr.'Multiple BP Lowest Date').ToString("MM/dd/yyyy")}
        $bcbs.'Systolic Value' = if($emr.'Multiple BP Lowest Systolic') {($emr.'Multiple BP Lowest Systolic')}
        $bcbs.'Diastolic Value' = if($emr.'Multiple BP Lowest Diastolic') {($emr.'Multiple BP Lowest Diastolic')}
        write-host ""
    }
    return $bcbsData
}