set-location "\\fileserver\it\apps\powershell"
function Get-fnComputerInventory {

    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\comp\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $adproc     = @(Get-ChildItem -Path "$PWD\app\active-directory\private\stored-procedure\Invoke-spAdComputer.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $adcomp     = @(Get-ChildItem -Path "$PWD\app\active-directory\private\ad-objects\Get-fnAdComputers.ps1"      -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $config + $adcomp + $adproc)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config, adproc, adcomp
    #endregion
    
    $startTimer = Start-Timer
    Write-Verbose "Start $($MyInvocation.MyCommand.Name)."
    
    $config = Get-fnConfig 
    $vpnIp = "$($config.vpn_ip_suffix)"  -replace '"',""

    # get computers joined to the domain in the last 5 hours
    $newComputers = Get-fnAdComputers -identity "hourly"
    $total = $newComputers.count 
    $cnt = 1
    write-host "$total computers modified in the last 5 hours"
    foreach($computer in $newComputers){
        Write-Information "Inserting $cnt of $total computers, $($computer.sAMAccountName)"
        Invoke-spAdComputer -computer $computer
        $cnt++
    }

    $computers = Invoke-spGetComputersToScan -count 50 -scanAfterHours 24
    $total = $computers.count
    $cnt = 1
    foreach($comp in $computers){
        Write-Information "Working on $cnt of $total... $($comp.ComputerName) "
        Get-fnWorkstationDetails -computer $comp.ComputerName -vpnIp $vpnIp
        $cnt++
    }
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Get-fnComputerInventory -Verbose -InformationAction continue
Stop-Transcript
