set-location "\\fileserver\it\apps\powershell"
function Set-fnWorkstationReboot {
    [CmdletBinding()]
    param ()

        #region - Import necessary configs and private functions #>

        Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
        $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
        $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\computers\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
        $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
        $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"                          -ErrorAction SilentlyContinue -Recurse)
    
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
        
        $startTimer = Start-Timer
        Write-Verbose "$($MyInvocation.MyCommand.Name): start."

        $weekday = ($today).DayOfWeek
        
        $frequency =  if($weekday -eq "sunday")  {'weekly'} else {'daily'}
        
        Write-Information "$weekday reboot $frequency"
        
        $computers = Invoke-fnSpWorkstationReboot -frequency $frequency

        foreach($computer in $computers){
            $ping = Test-Connection -ComputerName $computer.ComputerName -BufferSize 4 -count 1 -Quiet
            if($ping){
                write-verbose "rebooting $($computer.ComputerName)"

                try{
                    if($computer.ComputerName -eq "kphc-powershell"){
                        $totalTime = Stop-Timer -Start $startTimer
                        Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime"     
                    }
                    Restart-Computer -ComputerName $computer.ComputerName -force
                } catch {
                    write-verbose "try-catch fail $($computer.ComputerName)"
                }

            } else {
                write-verbose "cannot reboot $($computer.ComputerName). It is offline."
            }
        }

        $totalTime = Stop-Timer -Start $startTimer
        Write-Verbose "$($MyInvocation.MyCommand.Name): Workstation Details complete. It took $totalTime"     
                        

}

$Global:today = $null
$today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
Set-fnWorkstationReboot -Verbose -InformationAction Continue 
Stop-Transcript