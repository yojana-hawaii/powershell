function Get-fnBcbsColXclData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on col-xcl data"

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

        # reset before next patient
        $dos = $null
        $type = $null
        $x = $null

        # set gaps dates & values    
        if($emr.'Age-Relation Exclusion Date'){
            $type = "Age-Related ($($emr.'Age-Related Exclusion Detail') )"
            $dos = $emr.'Age-Relation Exclusion Date'
            $x = "a"
        } elseif ($emr.'Palliative Care Service Date'){
            $type = 'Palliative Care Service'
            $x = "p"
            $dos = $emr.'Palliative Care Service Date'
        } elseif ($emr.'Hospice Care Date'){
            $type = 'Hospice Care' 
            $dos = $emr.'Hospice Care Date'
            $x = "h"
        } elseif ($emr.'Colon Ca Dx Date'){
            $type = "Colon Cancer"
            $dos = $emr.'Colon Ca Dx Date'
            $x = "c"
        }
        
        if($dos){
            $dos = $dos.ToString("MM/dd/yyyy")
        }

        $bcbs.'Date of Service' = $dos
        $bcbs.'Exclusion Type' = $type
        $bcbs.Note = $x

    }
    return $bcbsData
}