function Stop-fnService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$serviceName
    )
    
    Write-Information "$($MyInvocation.MyCommand.Name) working on  $serviceName : $($computerName)"

    try{
        $service = Get-Service -ComputerName $computerName -Name $serviceName
        Stop-Service -InputObject ($service)


        Set-Service -ComputerName $computerName -Name $serviceName -StartupType "Disable"
       
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    Write-Information "$computerName service $ServiceName status $($service.Status) StartType $($service.StartType)"

    return $service.Status
}