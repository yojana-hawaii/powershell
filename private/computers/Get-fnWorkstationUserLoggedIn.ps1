function Get-fnWorkstationUserLoggedIn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $users = Get-WmiObject -ClassName Win32_NetworkLoginProfile -ComputerName $computerName| Select-Object  Name,  LastLogon

        $userObject = @()

        foreach($user in $users){
            $lastLogon = if($user.LastLogon){$user.LastLogon.substring(0, 8)}
            $lastLogon = if($user.LastLogon){([Datetime]::ParseExact($lastLogon, "yyyyMMdd", $null)) }

            $userObject += [PSCustomObject]@{
               ComputerName = $computerName
               UserLoggedIn = $user.Name
               UserLastLoggedInDate = $lastLogon
            }
        }
        return $userObject
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}