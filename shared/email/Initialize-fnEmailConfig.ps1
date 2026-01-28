function Initialize-fnEmailConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$sysaidemailtoboss = $null
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Initialize email config"

    $conf =  Get-fnEmailConfig

    $me = ($conf.myEmail) -replace '"',""
    $mySig = ($conf.mySig) -replace '"',""
    $email = @{
        smtp     = ($conf.smtp) -replace '"',""
        domain   = ($conf.domain) -replace '"',""

        from = $me
        to = $null
        cc = $null
        subject = $null
        body = $null

        bodyintro = ($conf.bodyintro) -replace '"',""
        bodyhtml = $null
        bodysig = "<p>Thank you<br />$mySig"

        me = $me
        mySig = $mySig

        bossName = ($conf.bossName) -replace '"',""
        bossEmail = ($conf.bossEmail) -replace '"',""

        helpdesk = (($conf.helpdesk) -replace '"',"") -replace "'", ""
        security = (($conf.security) -replace '"',"") -replace "'", ""
        emr      = (($conf.emr) -replace '"',"") -replace "'", ""
        billing  = (($conf.billing) -replace '"',"") -replace "'", ""
        hr       = (($conf.hr) -replace '"',"") -replace "'", ""
        queenB   = (($conf.queenB) -replace '"',"") -replace "'", ""

        missingSlipFrom = (($conf.missingSlipFrom) -replace '"',"") -replace "'", ""
        missingSlipCc   = ((($conf.missingSlipCc) -replace '"',"") -replace "'", "").Split(';')
        missingSlipCcBh = ((($conf.missingSlipCcBh) -replace '"',"") -replace "'", "").Split(';')

        orderTo = (($conf.orderTo) -replace '"',"") -replace "'", ""
        orderCC = (($conf.orderCC) -replace '"',"") -replace "'", ""
        orderSubject = "Incomplete Order Summary"
        supportStaffCC = (($conf.supportStaffCC) -replace '"',"") -replace "'", ""
        supportStaffFrom = (($conf.supportStaffFrom) -replace '"',"") -replace "'", ""
        incompleteOrderStepByStepProcess = ""
        
        proserviceSubject = (($conf.proserviceSubject) -replace '"',"") -replace "'", ""
                
        sysaidsubject =($conf.sysaidsubject) -replace '"',""
        sysaidbody1 =  ($conf.sysaidbody1) -replace '"',""
        sysaidbody2 =  ($conf.sysaidbody2) -replace '"',""
        sysaidbody3 =  ($conf.sysaidbody3) -replace '"',""
        sysaidemailtoboss = $sysaidemailtoboss
        sysaid2subject =($conf.sysaid2subject) -replace '"',""
        sysaid2body1 =  ($conf.sysaid2body1) -replace '"',""
        sysaid2body2 =  ($conf.sysaid2body2) -replace '"',""
        sysaid2body3 =  ($conf.sysaid2body3) -replace '"',""

        compExportSubject = ($conf.compExportSubject) -replace '"',""
        compExportBody = ($conf.compExportBody) -replace '"',""

        dentalSubject = ($conf.dentalSubject) -replace '"', ""
        dentalBody = ($conf.dentalBody) -replace '"', ""
        dentalTo = ($conf.dentalTo) -replace '"', ""

        enableUserSubject = ($conf.enableUserSubject) -replace '"', ""
        enableUserBody1 = ($conf.enableUserBody1) -replace '"', ""
        enableUserBody2 = ($conf.enableUserBody2) -replace '"', ""

        terminatedUserSubject = ($conf.terminatedUserSubject) -replace '"', ""
        terminatedUserBody1 = ($conf.terminatedUserBody1) -replace '"', ""
        terminatedUserBody2 = ($conf.terminatedUserBody2) -replace '"', ""
        terminatedUserBody3 = ($conf.terminatedUserBody3) -replace '"', ""

        inactiveUserSubject = ($conf.inactiveUserSubject) -replace '"', ""
        inactiveUserBody = ($conf.inactiveUserBody) -replace '"', ""
        removedFromGroupSubject = ($conf.removedFromGroupSubject) -replace '"', ""
        removedFromGroupBody = ($conf.removedFromGroupBody) -replace '"', ""
        managerEmail = $null
        fullname = $null

        vendorstudentsubject = ($conf.vendorstudentsubject) -replace '"', ""
        vendorstudentbody1 = ($conf.vendorstudentbody1) -replace '"', ""
        
    }
    return $email
}