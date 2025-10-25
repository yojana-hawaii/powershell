function Add-fnLapsUser {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ComputerName,
        [PsCustomObject]$laps
    )
    
    Write-Verbose "$($MyInvocation.MyCommand.Name): Create $($laps.Username) in $($ComputerName)"

    # make sure computer is online
    $ping = Test-Connection $ComputerName -Quiet -Count 1
    if(-not $ping){
        Write-Warning "$($ComputerName) offline"
        return
    }

    try{
        # check if user already exists
        $lapsUserExists = Assert-fnLapsUserExists -ComputerName $ComputerName -LapsUser $laps.Username
        if($lapsUserExists){
            return
        } 
        
        # create user if it does not exists
        Invoke-Command -ComputerName $computerName -ScriptBlock { 
            param($laps)
            New-LocalUser -Name $laps.Username -Description $laps.Description -Password $laps.Password  -PasswordNeverExpires -UserMayNotChangePassword -FullName $laps.FullName
        } -ArgumentList $laps
        
        # check if user now exists
        $lapsUserExistsNow = Assert-fnLapsUserExists -ComputerName $ComputerName -LapsUser $laps.Username
        if($lapsUserExistsNow){
            Write-Verbose "$($MyInvocation.MyCommand.Name): $($laps.Username) successfully added in $computerName"
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): failed to add $($laps.Username) in $computerName"
        }
    
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return    
}

