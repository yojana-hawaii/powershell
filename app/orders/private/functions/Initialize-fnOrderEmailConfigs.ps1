function Initialize-fnOrderEmailConfigs {
    [CmdletBinding()]
    param (

    )
    $emailConfig        = Get-fnEmailConfig
    
    Write-Information "$($MyInvocation.MyCommand.Name): : Initializing PSCustomObject for email"
    $email = [PSCustomObject]@{
        smtp            = ($emailConfig.smtp) -replace '"',""
        from            = ($emailConfig.myEmail) -replace '"',""
        me              = ($emailConfig.myEmail) -replace '"',""
        to              = (($emailConfig.orderTo) -replace '"',"").Split(';')
        cc              = (($emailConfig.orderCC) -replace '"',"").Split(';')
        supportcc       = (($emailConfig.supportStaffCC) -replace '"',"").Split(';')
        supportFrom     = ($emailConfig.supportStaffFrom) -replace '"',""
        bodyashtml      = $true
        emailSig        = ($emailConfig.mySig) -replace '"',""
 
        subject         = ""
        body            = ""

        htmlStart       = Set-fnEmailHtmlStart
        htmlEnd         = Set-fnEmailHtmlEnd

        emailBody1      = $null
        emailBody1a     = $null
        emailBody2      = $null
        emailBody2a     = $null
        emailBody3      = $null
        emailBody3a     = $null
        emailBody4      = $null      
        emailBody4a     = $null      
        emailBody5      = $null    
        emailBody5a     = $null    
        emailBody6      = $null
        emailBody6a     = $null
    }

    return $email
}