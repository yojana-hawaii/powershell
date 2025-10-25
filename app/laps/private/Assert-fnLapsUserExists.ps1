
function Assert-fnLapsUserExists{
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$ComputerName,
        [parameter()]
        [string]$LapsUser
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): Assert if $($lapsUser) exists in $($ComputerName)"


    $lapsUserExists = $false
    $serviceName = "WinRm"
    try {
        $service = Start-fnService -ComputerName $computerName -serviceName $serviceName -finalState "Auto"
        if($null -eq $service) { 
            throw "Problem access $ServiceName for $ComputerName"
        }
        if ($service.Status -ne 'Running') {
            throw "Could not start $serviceName for $computename"
            
        }

        $scriptBlock = { Get-LocalUser }
        $existingusers = Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock

    } catch {
        throw
    }

    foreach($user in $existingusers){
        if($user.Name -eq $LapsUser){
            Write-Verbose "$($MyInvocation.MyCommand.Name): $LapsUser already exists in $computerName"
            $lapsUserExists = $true
            break
        }
    }
    Write-Verbose "$($MyInvocation.MyCommand.Name): Final $serviceName Status $($service.Status)"

    return $lapsUserExists
}