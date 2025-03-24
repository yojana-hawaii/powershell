function Get-fnWorkstationDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computer,
        [Parameter(Mandatory)]
        [string]$vpnIp
    )
    
    $ping = Test-Connection $computer -Quiet -Count 1
    if($ping){
        $workstation =  Get-fnWorkstationSpecs -computerName $computer -vpnIp $vpnIp
        Invoke-fnSpWorkstationSpecs -workstation $workstation -Verbose
        
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
        
        $printers = Get-fnWorkstationPrinter -computerName $computer
        foreach( $printer in $printers){
            Invoke-fnSpWorkstationPrinters -printer $printer
        }
        $users = Get-fnWorkstationLocalUser -computerName $computer
        foreach($user in $users){
            Invoke-fnSpWorkstationLocalUser -localUser $user
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
    else {
        Invoke-fnSpWorkstationSpecsOffline -computerName $computer -Verbose 
    }
}