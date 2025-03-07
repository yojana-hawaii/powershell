function Stop-fnRemoteRegistryService {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Stopping registry service in $($computerName)"

    $serviceName = "RemoteRegistry"

    try{
        $service = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        $serviceObject = Get-Service -ComputerName $computerName -Name $serviceName
    
        if($service.StartType -ne 'Disabled'){
            Set-Service -Name $service.Name -StartupType Disabled -ComputerName $computerName
        }
        if($service.Status -eq 'Running'){
            Stop-Service -InputObject($serviceObject)
        }
    
        $service = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        Write-Verbose "$($MyInvocation.MyCommand.Name): $serviceName has been changed to $($service.Status)."
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $service
}