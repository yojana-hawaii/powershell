function Get-fnWorkstationDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computer,
        [Parameter(Mandatory)]
        [string]$vpnIp
    )
    
    $serviceName = "winrm"
    
    $ping = Test-Connection $computer -Quiet -Count 1
    if($ping){
        try {
            $service = Start-fnService -ComputerName $computer -serviceName $serviceName
            if($null -ne $service){

                $workstation =  Get-fnWorkstationSpecs -computerName $computer -vpnIp $vpnIp
                $workstation
                if($null -eq $workstation.SerialNumber){
                    Invoke-fnSpWorkstationSpecsOffline -computerName $computer -Verbose 
                    return
                }
                Invoke-fnSpWorkstationSpecs -workstation $workstation -Verbose
                
                $printers = Get-fnWorkstationPrinter -computerName $computer
                foreach( $printer in $printers){
                    Invoke-fnSpWorkstationPrinters -printer $printer
                }


                $users = Get-fnWorkstationLocalUser -computerName $computer
                foreach($user in $users){
                    Invoke-fnSpWorkstationLocalUser -localUser $user
                }



                $softwares = Get-fnWorkstationSoftware -computerName $computer
                foreach($software in $softwares){
                    Invoke-fnSpWorkstationSoftware -software $software -Verbose
                }

                if($workstation.IsVm -ne 1)
                {
                    $monitors = Get-fnWorkstationMonitor -computerName $computer
                    foreach($monitor in $monitors){
                        Invoke-fnSpWorkstationMonitors -monitor $monitor
                    }
                }
                
                $partitions = Get-fnWorkstationPartition -computerName $computer
                foreach($partition in $partitions){
                    Invoke-fnSpWorkstationPartition -parition $partition
                }

                $users = Get-fnWorkstationUserLoggedIn -computerName $computer
                foreach($user in $users){
                    Invoke-fnSpWorkstationUserLoggedIn -loggedInUser $user
                }
                $services = Get-fnWorkstationServices -computerName $computer
                foreach($service in $services){
                    Invoke-fnSpWorkstationServices -service $service -Verbose
                }
            }
            
        }
        catch {
            Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computer): $($_.Exception.Message)"
        }
        finally {
            Stop-fnService -computerName $computer -serviceName $serviceName -returnToOriginalStatus $true -original $service
        }
        
    }
    else {
        Invoke-fnSpWorkstationSpecsOffline -computerName $computer -Verbose 
    }
}