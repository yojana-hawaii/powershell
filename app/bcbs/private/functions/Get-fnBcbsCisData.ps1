function Get-fnBcbsCisData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Pulling on cis data"

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
        $bcbs.dtapsd1 = if($emr.'DTaP Imm 1st') {($emr.'DTaP Imm 1st').ToString("MM/dd/yyyy")}
        $bcbs.dtapsd2 = if($emr.'DTaP Imm 2nd') {($emr.'DTaP Imm 2nd').ToString("MM/dd/yyyy")}
        $bcbs.dtapsd3 = if($emr.'DTaP Imm 3rd') {($emr.'DTaP Imm 3rd').ToString("MM/dd/yyyy")}
        $bcbs.dtapsd4 = if($emr.'DTaP Imm 4th') {($emr.'DTaP Imm 4th').ToString("MM/dd/yyyy")}

        $bcbs.ipvsd1 = if($emr.'IPV Imm 1st') {($emr.'IPV Imm 1st').ToString("MM/dd/yyyy")}
        $bcbs.ipvsd2 = if($emr.'IPV Imm 2nd') {($emr.'IPV Imm 2nd').ToString("MM/dd/yyyy")}
        $bcbs.ipvsd3 = if($emr.'IPV Imm 3rd') {($emr.'IPV Imm 3rd').ToString("MM/dd/yyyy")}

        $bcbs.mmrsd1 = if($emr.'MMR Imm 1st') {($emr.'MMR Imm 1st').ToString("MM/dd/yyyy")}

        $bcbs.hibsd1 = if($emr.'HIB Imm 1st Dose Date') {($emr.'HIB Imm 1st Dose Date').ToString("MM/dd/yyyy")}
        $bcbs.hibsd2 = if($emr.'HIB Imm 2nd Dose Date') {($emr.'HIB Imm 2nd Dose Date').ToString("MM/dd/yyyy")}
        $bcbs.hibsd3 = if($emr.'HIB Imm 3rd Dose Date') {($emr.'HIB Imm 3rd Dose Date').ToString("MM/dd/yyyy")}

        $bcbs.hepbsd1 = if($emr.'HepB Imm 1st') {($emr.'HepB Imm 1st').ToString("MM/dd/yyyy")}
        $bcbs.hepbsd2 = if($emr.'HepB Imm 2nd') {($emr.'HepB Imm 2nd').ToString("MM/dd/yyyy")}
        $bcbs.hepbsd3 = if($emr.'HepB Imm 3rd') {($emr.'HepB Imm 3rd').ToString("MM/dd/yyyy")}

        $bcbs.vzvsd1 = if($emr.'VZV Imm 1st Date') {($emr.'VZV Imm 1st Date').ToString("MM/dd/yyyy")}

        $bcbs.pneumo_sd1 = if($emr.'PCV Imm 1st') {($emr.'PCV Imm 1st').ToString("MM/dd/yyyy")}
        $bcbs.pneumo_sd2 = if($emr.'PCV Imm 2nd') {($emr.'PCV Imm 2nd').ToString("MM/dd/yyyy")}
        $bcbs.pneumo_sd3 = if($emr.'PCV Imm 3rd') {($emr.'PCV Imm 3rd').ToString("MM/dd/yyyy")}
        $bcbs.pneumo_sd4 = if($emr.'PCV Imm 4th') {($emr.'PCV Imm 4th').ToString("MM/dd/yyyy")}

    }
    return $bcbsData
}