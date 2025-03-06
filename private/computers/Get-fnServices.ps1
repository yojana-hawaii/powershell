function Get-fnServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try{
        $services = Get-Service -ComputerName $computerName | Select-Object Name, DisplayName, Status, 
                                StartType, CanPauseAndContinue, CanShutdown, CanStop,
                                @{
                                    label = "ComputerName"
                                    expression = {$computerName}
                                }
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $services
}