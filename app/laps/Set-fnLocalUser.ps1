set-location "\\fileserver\it\apps\powershell"
function fnLocal_LapsUserExists{
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$computerName,
        [parameter()]
        [string]$lapsUser,
        [parameter()]
        [System.Array]$existingUsers
    )

    $lapsUserExists = $false

    foreach($user in $existingusers){
        if($user.Name -eq $lapsUser){
            Write-Verbose "$($MyInvocation.MyCommand.Name): $lapsUser already exists in $computerName"
            $lapsUserExists = $true
        }
    }
    return $lapsUserExists
}
function fnLocal_CreateLapsUsers{
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$computerName,
        [parameter()]
        [System.Object]$laps
    )

    $serviceName = "WinRm"
    
    try{
        $service = Start-fnService -ComputerName $computerName -serviceName $serviceName -finalState "Auto"
        if($null -ne $service -and $service.Status -eq 'Running')
        {
            $getScriptBlock = { Get-LocalUser }
            $existingusers = Invoke-Command -ComputerName $computerName -ScriptBlock $getScriptBlock
            
            $lapsUserExists = fnLocal_LapsUserExists -computerName $computerName -lapsUser $laps.Username -existingUsers $existingusers
           
            if($lapsUserExists){
                return
            } else {
                Invoke-Command -ComputerName $computerName `
                         -ScriptBlock { 
                                param($laps)
                                New-LocalUser -Name $laps.Username -Description $laps.Description -Password $laps.Password  -PasswordNeverExpires -UserMayNotChangePassword -FullName $laps.FullName
                            } -ArgumentList $laps
                }

            $newExistingUsers = Invoke-Command -ComputerName $computerName -ScriptBlock $getScriptBlock
            $lapsUserNowExists = fnLocal_LapsUserExists -computerName $computerName -lapsUser $laps.Username -existingUsers $newExistingUsers
            
            if($lapsUserNowExists){
                Write-Verbose "$($MyInvocation.MyCommand.Name): $($laps.Username) successfully added in $computerName"
            } else {
                Write-Warning "$($MyInvocation.MyCommand.Name): failed to add $($laps.Username) in $computerName"
            }
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    } 
    finally {
        # Stop-fnService -computerName $computerName -serviceName $serviceName -returnToOriginalStatus $true -original $service
        Write-Verbose "$($MyInvocation.MyCommand.Name): Final Remote Registry Status $($finalServiceStatus.Status)"
    } 

}


function Set-fnLocalUser {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\laps\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    
    foreach ($import in @($utility + $private + $sqlConn + $config)){
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
    
    $config             = Get-fnConfig 
    $lapsUser           = "$($config.localUser)"  -replace '"',""
    $lapsPwd            = "$($config.localUserPwd)"  -replace '"',""
    $encodedPwd         = ConvertTo-SecureString $lapsPwd -AsPlainText -Force
    $lapsFullname       = "$($config.localUserFullname)"  -replace '"',""
    $lapsDescription    = "$($config.localUserDescription)"  -replace '"',""
    
    $laps = [PSCustomObject]@{
        Username = $lapsUser
        Password = $encodedPwd
        Description = $lapsDescription
        FullName = $lapsFullname
    }

    $startTimer = Start-Timer
    
    $comp = "comp1"
    
    if($comp -eq "comp1")
    {
        $computers = Invoke-spGetComputersWithoutUser -Count 100 -username $laps.Username
        
        foreach($computer in $computers)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Create $($laps.Username) in $($computer.ComputerName)"
            # $computer.ComputerName
            $ping = Test-Connection $computer.computerName -Quiet -Count 1
            if($ping){
                fnLocal_CreateLapsUsers -computerName $computer.ComputerName -laps $laps
            } else {
                Write-Warning "$($computer.ComputerName) offline"
            }
        }
    } else {
        $ping = Test-Connection $comp -Quiet -Count 1
        if($ping){
            fnLocal_CreateLapsUsers -computerName $comp -laps $laps
        }
    }
        
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Local user $localUser addition complete. It took $totalTime" 
}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnLocalUser -Verbose -InformationAction continue
Stop-Transcript
