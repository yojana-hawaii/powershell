function Enable-fnAdAccount {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash,
        [array]$arr,
        [string]$path,
        [PSCustomObject]$object
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Enable user & verify account "
    $today = Get-Date -Format "MM/dd/yyyy"
    $enabledList = New-Object System.Collections.Generic.List[System.Object]

    try {
        # read the file for usernames and enable date
        $data = import-csv -Path $path

        foreach($line in $data){
            $enabledate = ([datetime]$line.date).ToString("MM/dd/yyyy")

            # enable if today is retun date
            if($enabledate -eq $today){
                Write-Verbose "Enabling $($line.username)"
                Enable-ADAccount -Identity $line.username
                $enabledList.Add($line.username) 

                # if successfully enabled remove from the list
                if((Get-ADUser -Identity $line.username).enabled){
                    Write-Verbose "User $($line.username) has been enabled."
                    $data = $data | Where-Object {$_.username -ne $line.username}
                }
            } else {
                Write-Verbose "$($line.username) not ready to enable. Wait until $($line.date)"
            }
        }
        # put the final list back after removing all the enabled users
        $data | Export-Csv -Path $path -NoTypeInformation
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $enabledList 
}