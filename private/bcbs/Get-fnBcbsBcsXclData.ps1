function Get-fnBcbsBcsXclData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on bcs-xcl data"

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
        $emr = $emrData | Where-Object {$_.MRN -eq $emrId -and $_.Exclusion -eq 'Y'}
        if([string]::IsNullOrEmpty($emr.MRN)){
            continue 
        }

        # set gaps dates & values
        if([string]::IsNullOrEmpty($emr.'Age-Relation Exclusion Date')){
            $type = "Age-Related ($($emr.'Age-Related Exclusion Detail') )"
            $dos = $emr.'Age-Relation Exclusion Date'
        } elseif ([string]::IsNullOrEmpty($emr.'Palliative Care Service Date')){
            $type = 'Palliative Care Service'
            $dos = $emr.'Palliative Care Service Date'
        } elseif ([string]::IsNullOrEmpty($emr.'Hospice Care Date')){
            $type = 'Hospice Care' 
            $dos = $emr.'Hospice Care Date'
        } elseif ([string]::IsNullOrEmpty($emr.'Mastectomy 1st Date')){
            $type = "$($emr.'Mastectomy Type') Mastectomy"
            $dos = $emr.'Mastectomy 1st Date'
        } elseif ([string]::IsNullOrEmpty($emr.'Mastectomy 2nd Date')){
            $type = "$($emr.'Mastectomy Type') Mastectomy"
            $dos = $emr.'Mastectomy 2nd Date'
        } 
        
        if($dos){
            $dos = $dos.ToString("MM/dd/yyyy")
        }

        $bcbs.'Exclusion Type' = $type
        $bcbs.'Date of Service' = $dos
    }
    return $bcbsData
}