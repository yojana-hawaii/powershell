set-location "\\fileserver\it\apps\powershell"
function New-fnITProductivityReport {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\sysaid\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $config + $emailConf)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf
    #endregion

    #region Initialize
    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."
    
    $sysaidConf = Get-fnSysaidConfig
    $emailtoboss = ($sysaidConf.emailtoboss) -replace '"', ""
    $email = Initialize-fnEmailConfig -sysaidemailtoboss $emailtoboss
    Remove-Variable sysaidConf
    #endregion

    $days = -7
    
    # send team summary email
    $summary = Invoke-spGetSummaryForAll -days $days
    Get-fnEmailConfig_SysaidTeamSummary -arr $summary -email $email
    Send-fnEmail -email $email

    
    # send individual summary email
    $admins = (Invoke-spGetAdmins -days $days).AssignedTo
    foreach($admin in $admins){
        $ticketGroupedByStatus = Get-fnOrganizeTickets -days $days -admin $admin
        Get-fnEmailConfig_SysaidIndividualSummary -groupedTicket $ticketGroupedByStatus -email $email -str $admin 
        Send-fnEmail -email $email
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnITProductivityReport -Verbose -InformationAction continue
Stop-Transcript