set-location "\\fileserver\it\apps\powershell"
function Set-fnDisableInactiveUsers {
    #region - Import necessary configs and private functions #>
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private    = @(Get-ChildItem -Path "$PWD\app\users\inactive-users\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $ouConf    = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnOuConfig.ps1" -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $emailConf + $private + $ouConf)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, emailConf, private, ouConf
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    Write-Verbose "GET INACTIVE USERS"
    $inactiveDays = 17
    $inactiveUsers = Get-fnInactiveUsers -$inactiveDays

    if($null -eq $inactiveUsers -or $inactiveUsers -eq "") {
        return
    }

    Write-Verbose "DISABLE USERS"
    Disable-fnInactiveUsers -users $inactiveUsers
    
    Write-Verbose "GROUP USERS BY MANAGER AND EMAIL"
    $grps = $inactiveUsers | Group-Object Manager
    foreach($grp in $grps){
        $email = Initialize-fnEmailConfig
        Get-fnEmailConfig_DisableInactiveUsers -email $email -groupedUsers $grp
        Send-fnEmail -email $email
    }
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Disable inactive users complete. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnDisableInactiveUsers -Verbose -InformationAction continue
Stop-Transcript
