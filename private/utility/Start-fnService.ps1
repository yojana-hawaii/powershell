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
        $service = Get-CimInstance -ClassName win32_Service -ComputerName $computerName -Filter "name='$serviceName'"
        Write-Information "$($MyInvocation.MyCommand.Name): $serviceName initial status was $($service.Status) and state $($service.State)."
    

        if($service.State -ne 'Running'){
            $initial = Get-Service -Name $serviceName -ComputerName $computerName
            start-service -InputObject ($initial)
            
            $final = Get-CimInstance -ClassName win32_Service -ComputerName $computerName -Filter "name='$serviceName'"
            Write-Information "$($MyInvocation.MyCommand.Name): $serviceName has been changed to $($final.StartMode) and state $($final.State)."
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $service
}
