set-location "\\fileserver\it\apps\powershell"
function Set-fnLocalUser {
    #region - Import necessary configs and private functions #>

    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
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
    Remove-Variable import, utility, private, sqlConn
    #endregion
    Write-Verbose "$($MyInvocation.MyCommand.Name):  Start laps creation"
    $startTimer = Start-Timer

    #region initialize
    
    $lapConf            = Get-fnLapsConfig 
    $lapsUser           = "$($lapConf.localUser)"  -replace '"',""
    $lapsPwd            = "$($lapConf.localUserPwd)"  -replace '"',""
    $encodedPwd         = ConvertTo-SecureString $lapsPwd -AsPlainText -Force
    $lapsFullname       = "$($lapConf.localUserFullname)"  -replace '"',""
    $lapsDescription    = "$($lapConf.localUserDescription)"  -replace '"',""
    
    $laps = [PSCustomObject]@{
        Username = $lapsUser
        Password = $encodedPwd
        Description = $lapsDescription
        FullName = $lapsFullname
    }

    Remove-Variable lapConf, lapsuser, lapsPwd, encodedPwd, lapsFullname, lapsDescription
    
    #endregion

    # change comp1 to specific computer to target one machine
    $comp = "comp1"
    
    if($comp -eq "comp1")
    {
        $computers = Invoke-spGetComputersWithoutUser -Count 100 -username $laps.Username
        
        foreach($computer in $computers)
        {
            Add-fnLapsUser -ComputerName $computer.ComputerName -laps $laps
        }
    } else {
        Add-fnLapsUser -ComputerName $comp -laps $laps
    }
        
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Local user $localUser addition complete. It took $totalTime" 
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnLocalUser -Verbose -InformationAction continue
Stop-Transcript
