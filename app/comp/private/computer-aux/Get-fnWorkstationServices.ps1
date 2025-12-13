function Get-fnWorkstationServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try{
        $services = Get-CimInstance -ClassName Win32_Service -ComputerName $computer | 
            Select-Object Name, DisplayName, State,StartMode, AcceptPause, AcceptStop, DelayedAutoStart, StartName
         
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $services
}