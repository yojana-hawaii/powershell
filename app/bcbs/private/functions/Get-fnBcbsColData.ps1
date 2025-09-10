function Get-fnBcbsColData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on col data"

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
        if ($emr.'Sigmoidoscopy Date') {
            $bcbs.'Flexible Sigmoidoscopy ' = 'X'
            $dos = $emr.'Signoidoscopy Date'
        } 
        if($emr.'CT Colonography Date'){
            $bcbs.'CT Colonography' = 'X'
            if($dos -lt $emr.'CT Colonography Date'){
                $dos = $emr.'CT Colonography Date'
            }
        } 
        if($emr.'sDNA FIT-DNA Test Date'){
            $bcbs.'FIT-DNA' =  'X'
            if($dos -lt $emr.'sDNA FIT-DNA Test Date'){
                $dos = $emr.'sDNA FIT-DNA Test Date'
            }
        }
        if ($emr.'Colonoscopy Date') {
            $bcbs.'Colonoscopy' = 'X'
            if($dos -lt $emr.'Colonoscopy Date'){
                $dos = $emr.'Colonoscopy Date'
            }
        } 
        if($emr.'FIT-FOBT Date') {
            $bcbs.'FOBT ' = 'X'
            if($dos -lt $emr.'FIT-FOBT Date'){
                $dos = $emr.'FIT-FOBT Date'
            }
        } 

        if($dos){
            $dos = $dos.ToString("MM/dd/yyyy")
        }

        $bcbs.'Date of Service' = $dos
        $dos = ""            
    }
    return $bcbsData
}