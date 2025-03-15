function Stop-fnService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName,
        [Parameter(Mandatory)]
        [string]$serviceName,
        [Parameter()]
        [PsCustomObject]$original,
        [Parameter()]
        [bool]$returnToOriginalStatus = $true
    )
    
    Write-Information "$($MyInvocation.MyCommand.Name) working on  $serviceName : $($computerName)"

    try{
        $initial = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        Write-Verbose "$($MyInvocation.MyCommand.Name): $serviceName initial status was $($initial.Status)."
        $service = Get-Service -ComputerName $computerName -Name $serviceName

    
        if($returnToOriginalStatus){
            Write-Information "$($MyInvocation.MyCommand.Name): Return to Original Status was $returnToOriginalStatus. Return to original state"
            
            Write-Information "$($MyInvocation.MyCommand.Name): Original Service $($original.Name), $($original.Status), $($original.StateType)"
            if($null -ne $original -and $initial.Name -eq $original.Name){
                if($initial.StartType -ne $original.StartType){
                    Set-Service -Name $initial.Name -StartupType $original.StartType -ComputerName $computerName
                }
                if($initial.Status -ne $original.Status -and $original.status -eq "stopped"){
                    Stop-Service -InputObject($service)
                }
            } else {
                Write-Warning "$($MyInvocation.MyCommand.Name): Return to Original Status was $returnToOriginalStatus. Cannot return to original state"

            }

        } else {
            # if not original status then disable service and stop service
            Write-Information "$($MyInvocation.MyCommand.Name): Return to Original Status was $returnToOriginalStatus. Stop Service"
 
            if($initial.StartType -ne 'Disabled'){
                Set-Service -Name $initial.Name -StartupType Disabled -ComputerName $computerName
            }
            if($initial.Status -eq 'Running'){
                Stop-Service -InputObject($service)
            }
        }
    
        $final = Get-Service -ComputerName $computerName -Name $serviceName | Select-Object Name, ServiceName, StartType, Status
        Write-Verbose "$($MyInvocation.MyCommand.Name): $serviceName has been changed to $($final.Status)."
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }

    return $final.Status
}