set-location "\\fileserver\it\apps\powershell"
function Set-fnWorkstationReboot {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\reboot\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
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
    Remove-Variable import, utility, private, sqlConn, config
    #endregion
        
    
    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."
    $today = Get-Date
    
    $rebootConf = Get-fnRebootConfig
    $initiater = ($rebootConf.initiator) -replace '"', ""

    $weekday = ($today).DayOfWeek    
    $frequency =  if($weekday -eq "sunday")  {'weekly'} else {'daily'}
    
    Write-Information "$weekday reboot $frequency"
    
    # $frequency = "weekly"
    $computers = Invoke-fnSpWorkstationReboot -frequency $frequency
    $total = $computers.count
    $cnt = 1


    foreach($computer in $computers){
        $ping = Test-Connection -ComputerName $computer.ComputerName -BufferSize 4 -count 1 -Quiet
        write-verbose "Working on $($computer.ComputerName) ... $cnt of $total"
        if($ping){
            Write-Information  "Online & rebooting $($computer.ComputerName)"

            try{
                if($computer.ComputerName -eq $initiater){
                    Write-Verbose "Skip $initiator for now."
                    continue
                }
                Restart-Computer -ComputerName $computer.ComputerName -force
            } catch {
                write-verbose "try-catch fail $($computer.ComputerName)"
            }

        } else {
            write-verbose "cannot reboot $($computer.ComputerName). It is offline."
        }
        $cnt++
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime"     
    
    if($frequency -eq "weekly"){
        write-verbose "finally restart $initiater"
        Restart-Computer -ComputerName $initiater -force

    }
                        

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnWorkstationReboot -Verbose -InformationAction continue
Stop-Transcript