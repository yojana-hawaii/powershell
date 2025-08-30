function Get-fnWorkstationServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try{
        $services = Invoke-Command -ComputerName $computerName `
            -ScriptBlock { 
                Get-Service | Select-Object Name, DisplayName, Status, 
                    StartType, CanPauseAndContinue, CanShutdown, CanStop
            }
         
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $services
}