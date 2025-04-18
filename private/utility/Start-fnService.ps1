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
        if($service.State -ne "Running"){
            Start-Service -InputObject ($service)
        }
        
        Set-Service -ComputerName $computerName -Name $serviceName -StartupType $finalState
        return $service
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}