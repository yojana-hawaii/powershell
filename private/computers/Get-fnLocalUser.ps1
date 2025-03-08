function fnLocal_AccountType($type){
    $value = ""
    switch([int]$type)
    {
        256     {$value = "Temporary duplicayr accoint"}
        512     {$value = "Normal account"}
        2048    {$value = "Interdomain trust accoount"}
        4096    {$value = "Workstation trust account"}
        8192    {$value = "Server trust account"}
        default {$value = "$type"}
    }
    return $value
}
function Get-fnLocalUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        Get-WmiObject -ComputerName $computerName -Class Win32_UserAccount |
                Select-Object Name, Status, PasswordExpires, 
                        Description, Disabled, FullName, InstallDate, LocalAccount, Lockout,
                        PasswordChangeable, PasswordRequired,
                        @{
                            label = "AccountType"
                            expression = {fnLocal_AccountType($_.AccountType)}
                        },
                        @{
                            label = "ComputerName"
                            expression = {$computerName}
                        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}
