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

    $actionsTaken = "Daily clean up:"
    foreach($group in $groupsToEmpty){
        Write-Verbose "Checking group: $group"
        $members = Get-ADGroupMember -Identity $group
        
        foreach ($member in $members){
            $actionsTaken += "Removed $($member.name) from $group<br />"
            Remove-ADGroupMember -Identity $group -Members $member -Confirm:$False
        }
    }

    $email = Initialize-fnEmailConfig
    Get-fnEmailConfig_RemoveUserGroup -email $email -actionsTaken $actionsTaken
    Send-fnEmail -email $email
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Remove users from groups. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnRemoveUsersFromGroups -Verbose -InformationAction continue
Stop-Transcript

