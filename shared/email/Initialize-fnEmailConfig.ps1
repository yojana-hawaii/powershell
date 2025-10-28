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

        missingSlipFrom = (($conf.hr) -replace '"',"") -replace "'", ""
        missingSlipCc   = ((($conf.missingSlipCc) -replace '"',"") -replace "'", "").Split(';')
        missingSlipCcBh = ((($conf.missingSlipCcBh) -replace '"',"") -replace "'", "").Split(';')

        orderTo = (($conf.orderTo) -replace '"',"") -replace "'", ""
        orderCC = (($conf.orderCC) -replace '"',"") -replace "'", ""
        supportStaffCC = (($conf.supportStaffCC) -replace '"',"") -replace "'", ""
        supportStaffFrom = (($conf.supportStaffFrom) -replace '"',"") -replace "'", ""
        
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
        enableUserBody = ($conf.enableUserBody) -replace '"', ""
        terminatedUserSubject = ($conf.terminatedUserSubject) -replace '"', ""
        terminatedUserBody = ($conf.terminatedUserBody) -replace '"', ""
        inactiveUserSubject = ($conf.inactiveUserSubject) -replace '"', ""
        inactiveUserBody = ($conf.inactiveUserBody) -replace '"', ""
        removedFromGroupSubject = ($conf.removedFromGroupSubject) -replace '"', ""
        removedFromGroupBody = ($conf.removedFromGroupBody) -replace '"', ""
    }
    return $email
}