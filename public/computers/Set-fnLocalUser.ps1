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
    [CmdletBinding()]
    param (
    )

    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"                           -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"                                    -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\computers\*.ps1"                         -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"                     -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($utility + $sqlConection + $storedProcedure + $configHelper)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    $import = $null
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


$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "MM-dd-yyyy"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$mmddyyyy.txt" -Append
Set-fnLocalUser  -Verbose -InformationAction Continue
Stop-Transcript
