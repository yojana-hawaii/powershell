function Start-fnService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$serviceName
    )
    Write-Information "$($MyInvocation.MyCommand.Name) starting  $serviceName : $($computerName)"
    
    try {
        $initial = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        Write-Verbose "$($MyInvocation.MyCommand.Name): $serviceName initial status was $($initial.Status)."

        $service = Get-Service -ComputerName $computerName -Name $serviceName
    
        if($initial.StartType -ne 'Manual'){
            Set-Service -Name $initial.Name -StartupType Manual -ComputerName $computerName
        }
        if($initial.Status -ne 'Running'){
            start-service -InputObject ($service)
        }
        $final = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        Write-Verbose "$($MyInvocation.MyCommand.Name): $serviceName has been changed to $($final.Status)."
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $initial
}