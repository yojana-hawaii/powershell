set-location "\\fileserver\it\apps\powershell"

function Set-fnEnableReturningUsers {
    #region - Import necessary configs and private functions #>
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private    = @(Get-ChildItem -Path "$PWD\app\users\enable-users\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlLookup  = @(Get-ChildItem -Path "$PWD\shared\SqlLookup\Invoke-spGetUserAndManagerDetails.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $emailConf + $private + $sqlLookup + $sqlConn + $config)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, emailConf, private, sqlLookup, sqlConn, config
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $path =  "$pwd\shared-ignore\user-input\enable-user-5am.csv"
    $enabledUserList = Enable-fnAdAccount -path $path

    if($enabledUserList -ne ""){
        $email = Initialize-fnEmailConfig

        foreach($staff in $enabledUserList){

            try {
                $userDetail = Invoke-spGetUserAndManagerDetails -username $staff
            }
            catch {
                Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
            }
            
            $email.managerEmail = $userDetail.ManagerEmail
            $email.fullname = $userDetail.DisplayName
            Get-fnEmailConfig_EnableReturningUsers -email $email
            Send-fnEmail -email $email
        }
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Enable inactive users complete. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
# $verbosePreference = "continue"
$InformationPreference = "continue"
Set-fnEnableReturningUsers -Verbose -InformationAction continue
Stop-Transcript