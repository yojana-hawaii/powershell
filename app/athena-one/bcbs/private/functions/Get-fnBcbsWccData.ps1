function Get-fnBcbsWccData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on wcc data"

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
        write-host $emrId
        # set gaps dates & values  
        $visits = Invoke-fnGetBcbsApprovedStructuredData_UnpivotRownumberPivot -row $emr
        $bcbs.'Visit 1' = if(-not [string]::IsNullOrEmpty($visits[1])) {($visits[1]).ToString("MM/dd/yyyy")}
        $bcbs.'Visit 2' = if(-not [string]::IsNullOrEmpty($visits[2])) {($visits[2]).ToString("MM/dd/yyyy")}
        $bcbs.'Visit 3' = if(-not [string]::IsNullOrEmpty($visits[3])) {($visits[3]).ToString("MM/dd/yyyy")}
        $bcbs.'Visit 4' = if(-not [string]::IsNullOrEmpty($visits[4])) {($visits[4]).ToString("MM/dd/yyyy")}
        $bcbs.'Visit 5' = if(-not [string]::IsNullOrEmpty($visits[5])) {($visits[5]).ToString("MM/dd/yyyy")}
        $bcbs.'Visit 6' = if(-not [string]::IsNullOrEmpty($visits[6])) {($visits[6]).ToString("MM/dd/yyyy")}
    }
    return $bcbsData
}