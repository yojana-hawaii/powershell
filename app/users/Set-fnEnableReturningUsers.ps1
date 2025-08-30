set-location "\\fileserver\it\apps\powershell"

function Set-fnEnableReturningUsers {
    [CmdletBinding()]
    param (
        
    )
    #region - Import necessary configs and private functions #>
    $emailConfig        = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnEmailConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"                        -ErrorAction SilentlyContinue -Recurse)
    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($utility + $emailConfig)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }

    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $emailConfig =  Get-fnEmailConfig

    $email = @{
        Smtp            = ($emailConfig.smtp) -replace '"',""
        To              = ($emailConfig.helpdesk) -replace '"',""
        From            = ($emailConfig.myEmail) -replace '"',""
        Sig             = ($emailConfig.mySig) -replace '"',""
        Subject         = "Users enabled from return list"
        Body            = ""
    }
    
    $path =  "$pwd\shared-ignore\user-input\enable-user-5am.csv"
    $file = import-csv -Path $path 

    $enabledList = ""

    $now = Get-Date -Format "MM/dd/yyyy"
    foreach($line in $file){
        $enabledate = ([datetime]$line.date).ToString("MM/dd/yyyy")

        # enable and remove from csv
        if($enabledate -eq $now){
            Write-Verbose "Enabling $($line.username)"
            Enable-ADAccount -Identity $line.username
            $enabledList = $enabledList + ", " + $line.username

            if((Get-ADUser -Identity $line.username).enabled){
                Write-Verbose "User $($line.username) has been enabled."
                $file = $file | Where-Object {$_.username -ne $line.username}
            }
        } else {
            Write-Verbose "$($line.username) not ready to enable. Wait until $($line.date)"
        }
    }

    $file | Export-Csv -Path $path -NoTypeInformation

    if($enabledList -ne ""){
        $email.body = "Hello all, This is an automated email." + 
            "<br><br>The following users from return list have been actived. 
            <br><br>You can add return user and return date in 
            <br> \\fileserver\it\apps\powershell\shared-ignore\user-input\enable-user-5am.csv<br><br> 
            Usernames: $($enabledList.Substring(1))
            <br><br>Thank you.<br>$($email.sig)"

        Send-MailMessage -smtpserver $email.smtp -from $email.from -to $email.to -subject $email.subject -body $email.body -bodyashtml

    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Enable inactive users complete. It took $totalTime" 

}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnEnableReturningUsers -Verbose -InformationAction continue
Stop-Transcript