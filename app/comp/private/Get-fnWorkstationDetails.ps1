function Get-fnWorkstationDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computer,
        [Parameter(Mandatory)]
        [string]$vpnIp
    )
    
    Write-Information "$($MyInvocation.MyCommand.Name): workstation details for $($computer)"

    $readyForScan = Get-fnReadyForScan -computer $computer
    if(-not $readyForScan) {return}

    # Get computer specs
    $workstation =  Get-fnWorkstationSpecs -computerName $computer -vpnIp $vpnIp
    Invoke-fnSpWorkstationSpecs -workstation $workstation
    $workstation

    # Get local users
    $users = Get-fnWorkstationLocalUser -computerName $computer
    foreach($user in $users){
        Invoke-fnSpWorkstationLocalUser -localUser $user
    }

    # Get any user that has logged in - local or domain
    $users = Get-fnWorkstationUserLoggedIn -computerName $computer
    foreach($user in $users){
        Invoke-fnSpWorkstationUserLoggedIn -loggedInUser $user
    }

    # Get printer specs
    $printers = Get-fnWorkstationPrinter -computerName $computer
    foreach( $printer in $printers){
        Invoke-fnSpWorkstationPrinters -printer $printer
    }

    # Get drive partition
    $partitions = Get-fnWorkstationPartition -computerName $computer
    foreach($partition in $partitions){
        Invoke-fnSpWorkstationPartition -parition $partition
    }

    # Get installed computers
    $softwares = Get-fnWorkstationSoftware -computerName $computer
    foreach($software in $softwares){
        # some returns had stopped and not array of software details
        if( $software -eq "Stopped"){
            Write-Warning "$software is not array. Skip."
            continue
        }
        Invoke-fnSpWorkstationSoftware -software $software 
    }
        
    # Get services and status
    $services = Get-fnWorkstationServices -computerName $computer
    foreach($service in $services){
        Invoke-fnSpWorkstationServices -service $service -computerName $computer
    }
    
    # VM does not have monitor - wmi causing problem
    if($workstation.IsVm -ne 1){
        $monitors = Get-fnWorkstationMonitor -computerName $computer
        foreach($monitor in $monitors){
            Invoke-fnSpWorkstationMonitors -monitor $monitor
        }
    }
}