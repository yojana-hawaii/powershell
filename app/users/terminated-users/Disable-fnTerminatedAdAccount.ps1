function Disable-fnTerminatedAdAccount {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$path
    )
    Write-Information "$($MyInvocation.MyCommand.Name): disable terminated users "
    $data = import-csv -Path $path 
    $today = Get-Date -Format "MM/dd/yyyy"

    $disabledList = New-Object System.Collections.Generic.List[System.Object]

    #try cath when there is possibility of exception
    try {
        foreach($line in $data){
            $disabledate = ([datetime]$line.date).ToString("MM/dd/yyyy")

            # disable and remove from csv
            if($disabledate -eq $today){
                Write-Verbose "Disabling $($line.username)"
                Disable-ADAccount -Identity $line.username
                $disabledList.Add($line.username)

                if(-not(Get-ADUser -Identity $line.username).enabled){
                    Write-Verbose "User $($line.username) has been disabled."
                    $data = $data | Where-Object {$_.username -ne $line.username}
                }
            } else {
                Write-Verbose "$($line.username) not ready to disable. Wait until $($line.date)"
            }
        }

        $data | Export-Csv -Path $path -NoTypeInformation
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $disabledList
}