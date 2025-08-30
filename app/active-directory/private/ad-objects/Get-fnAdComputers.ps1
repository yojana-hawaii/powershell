function fnLocal_hasLaps($computerName){
    $laps = Get-LapsADPassword -Identity $computerName
    $hasLaps = if($null -ne $laps){1}else{0}
    return $hasLaps
}
function fnLocal_lapsExpirationDate($computerName){
    $laps = Get-LapsADPassword -Identity $computerName | Select-Object ExpirationTimeStamp
    return $laps.ExpirationTimeStamp
}
function fnLocal_hasBitlocker($computerName){
    $bit = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation' " -SearchBase $computerName
    $hasBit = if($null -ne $bit){1}else{0}
    return $hasBit
}
function Get-fnAdComputers {
    [CmdletBinding()]
    param (
        [parameter()]
        [bool]$enabled = $true,
        [parameter()]
        [bool]$server = $false,
        [parameter()]
        [string]$identity = "all"
    )

    $filter = "Enabled -eq '$enabled' -and OperatingSystem -notlike '*server*' "

    if($server){
        Write-Information "Get Servers"
        $filter = "OperatingSystem -like '*server*'"
    } 
    
    if($identity -ne 'all') {
        Write-Information "Get Individual Machine"
        $filter = "name -eq '$identity'"
    }
    if($identity -eq 'hourly'){
        $hours = 5
        $date = (get-date).AddHours(-$hours)
        Write-Information "Get AD computer changes in last $hours hours since $date."
        $filter = "Modified -gt `$date "
    }
    Write-Verbose "$($MyInvocation.MyCommand.Name) with filter: $filter"

   


    try {
        $computers = Get-ADComputer -Filter $filter -Properties *  | 
            Select-Object @{    
                    label="ComputerName"
                    expression={$_.Name}   
                },
                @{
                    label="Enabled"
                    expression={if($_.Enabled){1}else{0}}
                },
                @{
                    label="hasBitlocker"
                    expression={fnLocal_hasBitlocker($_.DistinguishedName)}
                },
                @{
                    label="hasLaps"
                    expression={fnLocal_hasLaps($_.Name)}
                }, 
                DistinguishedName,
                @{
                    label="OU"
                    expression={$_.CanonicalName}
                },
                sAMAccountName, IPV4Address, 
                OperatingSystem, OperatingSystemVersion,
                @{
                    label="Description"
                    expression={$_.Description -replace "'", ""}
                },
                @{
                    label="CreatedDate"
                    expression={$_.Created}
                },
                @{
                    label="ModifiedDate"
                    expression={$_.Modified}
                },
                @{
                    label="BitLockerPasswordDate"
                    expression={Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation' " -SearchBase $_.DistinguishedName -Properties whenCreated |
                                    Sort-Object whenCreated -Descending | 
                                    Select-Object -First 1 | 
                                    Select-Object -ExpandProperty whenCreated} 
                },
                @{
                    label="lapsExpirationDate"
                    expression={fnLocal_lapsExpirationDate($_.Name)}
                },
                LastLogonDate, LogonCount, UserAccountControl
                # @{
                #     label="UserAccountControl"
                #     expression={Get-fnUserAccountControlValue -userAccountControlFlag $_.UserAccountControl}
                # }
                   
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
    }      
    return $computers
    
}