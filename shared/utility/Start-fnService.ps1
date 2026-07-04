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
        $service = Invoke-Command -ComputerName $computerName -ScriptBlock {
            param($serviceName, $finalState)
            $service = Get-Service $serviceName

            # disabled service cannot be started
            if($service.StartType -eq "disabled"){
                Set-Service -Name $serviceName -StartupType "Manual"
            }

            # start service if it is not running
            if($service.Status -eq "Running"){
                Start-Service -InputObject $service
            }

            # set the final state of the service
            if($finalState -eq "Auto"){
                Set-Service -Name $serviceName -StartupType $finalState
            }

            # return from invoke-command
            $service
        } -ArgumentList $serviceName, $finalState



        Write-Information "$($MyInvocation.MyCommand.Name): $computerName service $ServiceName status $($service.Status) StartType $($service.StartType)"
        return $service
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}