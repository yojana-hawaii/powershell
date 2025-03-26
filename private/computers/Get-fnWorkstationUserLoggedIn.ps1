function Get-fnWorkstationUserLoggedIn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $users = Get-CimInstance -ClassName Win32_NetworkLoginProfile -ComputerName $computerName| Select-Object  Name,  LastLogon

        $userObject = @()

        foreach($user in $users){
            $userObject += [PSCustomObject]@{
               ComputerName = $computerName
               UserLoggedIn = $user.Name
               UserLastLoggedInDate = $user.LastLogon
            }
        }
        return $userObject
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}