set-location "\\fileserver\it\apps\powershell"

function Set-fnDisableTerminatedUser {
    #region - Import necessary configs and private functions #>
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private    = @(Get-ChildItem -Path "$PWD\app\users\terminated-users\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
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

    $path =  "$pwd\shared-ignore\user-input\disable-user-5pm.csv"
    $disabledUserList = Disable-fnTerminatedAdAccount -path $path

    if($disabledUserList -ne ""){
        $email = Initialize-fnEmailConfig

        foreach($term in $disabledUserList){
            try{
                $userDetail = Invoke-spGetUserAndManagerDetails -username $term
            } catch {
                Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
            }
            $email.managerEmail = $userDetail.ManagerEmail
            $email.fullname = $userDetail.DisplayName
            Get-fnEmailConfig_DisableTerminated -email $email
            Send-fnEmail -email $email
        }
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Disable inactive users complete. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnDisableTerminatedUser -Verbose -InformationAction continue
Stop-Transcript