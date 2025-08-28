function Get-fnBcbsBcsData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on BCS data"
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
        $emr = $emrData | Where-Object {$_.MRN -eq $emrId -and $_.Exclusion -eq 'N'}
        if([string]::IsNullOrEmpty($emr.MRN)){
            continue 
        }

        # set gaps dates & values
        $bcbs.'Date of Service' = if($emr.'Breast Cancer Screen Date') {($emr.'Breast Cancer Screen Date').ToString("MM/dd/yyyy")}
    }
    
    return $bcbsData
}