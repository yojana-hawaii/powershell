set-location "\\fileserver\it\apps\powershell"
function Get-fnComputerDetails {
    [CmdletBinding()]
    param (
    )

    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"                          -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\computers\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\computers\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($private + $utility + $sqlConection + $storedProcedure + $configHelper)){
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
    
    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."
    
    $config = Get-fnConfig 
    $vpnIp = "$($config.vpn_ip_suffix)"  -replace '"',""

    $computers = Invoke-spGetComputersToScan -count 50 -scanAfterHours 24
    $total = $computers.count
    $cnt = 1
    foreach($comp in $computers){
        Write-Information "Working on $cnt of $total... $($comp.ComputerName) "
        Get-fnWorkstationDetails -computer $comp.ComputerName -vpnIp $vpnIp
        $cnt++
    }
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}


$Global:today = $null
$today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
Get-fnComputerDetails -InformationAction Continue -verbose
Stop-Transcript
