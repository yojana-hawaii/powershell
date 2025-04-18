function Start-fnService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$serviceName,
        [Parameter(Mandatory)]
        [string]$finalState
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Start $serviceName in $($computerName)"
    
    try {
        $service = Get-Service -ComputerName $computerName -Name $serviceName

        if($service.StartType -eq "disabled"){
            Set-Service -ComputerName $computerName -Name $serviceName -StartupType "Manual"
        }

        if($service.State -ne "Running"){
            Start-Service -InputObject ($service)
        }
        if($finalState -eq "Auto"){
            Set-Service -ComputerName $computerName -Name $serviceName -StartupType $finalState
        }
        Write-Information "$computerName service $ServiceName status $($service.Status) StartType $($service.StartType)"
        return $service
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}