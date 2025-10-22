set-location "\\fileserver\it\apps\powershell"

function Set-fnDisableTerminatedUser {
    [CmdletBinding()]
    param (
        
    )
    #region - Import necessary configs and private functions #>
    $utility            = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"                        -ErrorAction SilentlyContinue -Recurse)
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($utility + $emailConf)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf

    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $emailConfig =  Get-fnEmailConfig

    $email = @{
        Smtp            = ($emailConfig.smtp) -replace '"',""
        To              = ($emailConfig.helpdesk) -replace '"',""
        From            = ($emailConfig.myEmail) -replace '"',""
        Sig             = ($emailConfig.mySig) -replace '"',""
        Subject         = "Users disabled from termination list"
        Body            = ""
    }

    $path =  "$pwd\shared-ignore\user-input\disable-user-5pm.csv"
    $file = import-csv -Path $path 

    $disabledList = ""

    $now = Get-Date -Format "MM/dd/yyyy"
    foreach($line in $file){
        $disabledate = ([datetime]$line.date).ToString("MM/dd/yyyy")

        # disable and remove from csv
        if($disabledate -eq $now){
            Write-Verbose "Disabling $($line.username)"
            Disable-ADAccount -Identity $line.username
            $disabledList = $disabledList + ", " + $line.username

            if(-not(Get-ADUser -Identity $line.username).enabled){
                Write-Verbose "User $($line.username) has been disabled."
                $file = $file | Where-Object {$_.username -ne $line.username}
            }
        } else {
            Write-Verbose "$($line.username) not ready to disable. Wait until $($line.date)"
        }
    }

    $file | Export-Csv -Path $path -NoTypeInformation

    if($disabledList -ne ""){
        $email.body = "Hello all, This is an automated email." + 
            "<br><br>The following users from termination list have been disabled. 
            <br><br>You can add terminated user and termination date in 
            <br> \\fileserver\it\apps\powershell\shared-ignore\user-input\disable-user-5pm.csv <br><br>
            Usernames: $($disabledList.Substring(1))
            <br><br>Thank you.<br>$($email.Sig)"


        Send-MailMessage -smtpserver $email.smtp -from $email.from -to $email.to -subject $email.subject -body $email.body -bodyashtml

    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Disable inactive users complete. It took $totalTime" 

}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnDisableTerminatedUser -Verbose -InformationAction continue
Stop-Transcript