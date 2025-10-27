function Initialize-fnEmailConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$param,
        [string]$str = $null
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Initialize email config"

    $me = ($param.myEmail) -replace '"',""
    $mySig = ($param.mySig) -replace '"',""
    $email = @{
        smtp     = ($param.smtp) -replace '"',""
        domain   = ($param.domain) -replace '"',""

        from = $me
        to = $null
        cc = $null
        subject = $null
        body = $null

        bodyintro = ($param.bodyintro) -replace '"',""
        bodyhtml = $null
        bodysig = "<p>Thank you<br />$mySig"

        me = $me
        mySig = $mySig

        bossName = ($param.bossName) -replace '"',""
        bossEmail = ($param.bossEmail) -replace '"',""

        helpdesk = (($param.helpdesk) -replace '"',"") -replace "'", ""
        security = (($param.security) -replace '"',"") -replace "'", ""
        emr      = (($param.emr) -replace '"',"") -replace "'", ""
        billing  = (($param.billing) -replace '"',"") -replace "'", ""
        hr       = (($param.hr) -replace '"',"") -replace "'", ""

        missingSlipFrom = (($param.hr) -replace '"',"") -replace "'", ""
        missingSlipCc   = ((($param.missingSlipCc) -replace '"',"") -replace "'", "").Split(';')
        missingSlipCcBh = ((($param.missingSlipCcBh) -replace '"',"") -replace "'", "").Split(';')

        orderTo = (($param.orderTo) -replace '"',"") -replace "'", ""
        orderCC = (($param.orderCC) -replace '"',"") -replace "'", ""
        supportStaffCC = (($param.supportStaffCC) -replace '"',"") -replace "'", ""
        supportStaffFrom = (($param.supportStaffFrom) -replace '"',"") -replace "'", ""
        
        proserviceSubject = (($param.proserviceSubject) -replace '"',"") -replace "'", ""
                
        sysaidsubject =($param.sysaidsubject) -replace '"',""
        sysaidbody1 =  ($param.sysaidbody1) -replace '"',""
        sysaidbody2 =  ($param.sysaidbody2) -replace '"',""
        sysaidbody3 =  ($param.sysaidbody3) -replace '"',""
        sysaidemailtoboss = $str
        sysaid2subject =($param.sysaid2subject) -replace '"',""
        sysaid2body1 =  ($param.sysaid2body1) -replace '"',""
        sysaid2body2 =  ($param.sysaid2body2) -replace '"',""
        sysaid2body3 =  ($param.sysaid2body3) -replace '"',""

        compExportSubject = ($param.compExportSubject) -replace '"',""
        compExportBody = ($param.compExportBody) -replace '"',""

        dentalSubject = ($param.dentalSubject) -replace '"', ""
        dentalBody = ($param.dentalBody) -replace '"', ""
        dentalTo = ($param.dentalTo) -replace '"', ""
    }
    return $email
}