set-location "\\fileserver\it\apps\powershell"

function Set-fnRemoveUsersFromGroups {
    #region - Import necessary configs and private functions #>
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $private    = @(Get-ChildItem -Path "$PWD\app\users\remove-from-group\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlLookup  = @(Get-ChildItem -Path "$PWD\app\shared\SqlLookup\Invoke-spGetUserAndManagerDetails.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $emailConf + $private + $sqlLookup + $sqlConn + $config)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, emailConf, private, sqlLookup, sqlConn, config
    #endregion


    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $config = Get-fnConfig 
    $groupsToEmpty = (($config.groupsToEmpty) -replace '"', "") -split ","
    $statusCheck = $false

    $today = Get-Date -Format "MM/dd/yyyy"
    $path =  "$pwd\shared-ignore\user-input\disable-youtube-5pm.csv"
    $data = Import-Csv -Path $path
    $youtube_users_to_keep = $data | Where-Object {([datetime]$_.date) -gt $today}

    $actionsTaken = "<p>Daily clean up:</p><p>For more than one day access to youtube, add user to $path with removal date</p>"
    foreach($group in $groupsToEmpty){
        Write-Verbose "Checking group: $group"
        $members = Get-ADGroupMember -Identity $group

        if($group -like "*youtube*"){

            $members = (
                    Compare-Object -Property username `
                        -ReferenceObject ($members | Select-Object @{ N='username'; E={$_.SamAccountName} }) `
                        -DifferenceObject ($youtube_users_to_keep | Select-Object username)
                    ) | 
                    Where-Object {$_.SideIndicator -eq "<="} |
                    ForEach-Object  {Get-ADUser $_.username}
                

        }

        foreach ($member in $members){
            $actionsTaken += "Removed $($member.name) from $group<br />"
            Remove-ADGroupMember -Identity $group -Members $member -Confirm:$False
            $youtube_users_to_keep  | Export-Csv -Path $path -NoTypeInformation
            $statusCheck = $true
        }
    }

    if($statusCheck){
        $email = Initialize-fnEmailConfig
        Get-fnEmailConfig_RemoveUserGroup -email $email -actionsTaken $actionsTaken
        Send-fnEmail -email $email
    }

    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Remove users from groups. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnRemoveUsersFromGroups -Verbose -InformationAction continue
Stop-Transcript

