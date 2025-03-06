set-location "\\fileserver\it\apps\powershell"
function New-fnComputerDetails {
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
    
    $computer = "comp1"
    $ping = Test-Connection $computer -Quiet -Count 1
    if($ping){
        $compDetails =  Get-fnWorkstationSpecs -computerName $computer
        Invoke-fnSpWorkstationSpecs -workstation $compDetails -Verbose
        
        $services = Get-fnServices -computerName $computer
        foreach($service in $services){
            Invoke-fnSpWorkstationServices -workstation $service -Verbose
        }
    }
    else {
        Invoke-fnSpWorkstationSpecsOffline -computerName $computer -Verbose 
    }

    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime" 
}


$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "MM-dd-yyyy"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$mmddyyyy.txt" -Append
New-fnComputerDetails  -Verbose -InformationAction Continue
Stop-Transcript
