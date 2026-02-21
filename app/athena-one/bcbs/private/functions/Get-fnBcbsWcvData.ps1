function Get-fnBcbsWcvData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on wcv data"

    foreach($bcbs in $bcbsData){
        # find equivalent emr id
        $emrId = (Invoke-fnGetEmrIdFromBcbsId -BcbsId $bcbs.'HMSA MbrUID').AthenaPid
        if([string]::IsNullOrEmpty($emrId)){ 
            $bcbs.'Medical Record' = "no-patient-match"
            continue
        }

        $dos = $null
        
        #set emr id
        $bcbs.'Medical Record'  = $emrId

        # find data for that emr id
        $emr = $emrData | Where-Object {$_.MRN -eq $emrId}
        if([string]::IsNullOrEmpty($emr.MRN)){
            continue 
        }

        $bcbs.'Date of Service' = if($emr.'Most Recent Annual Well-Child Care (3-21 yrs) 3y-21y') {($emr.'Most Recent Annual Well-Child Care (3-21 yrs) 3y-21y').ToString("MM/dd/yyyy")}

        $bcbs.Note = 1
    }
    return $bcbsData
}