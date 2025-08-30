set-location "\\fileserver\it\apps\powershell"

function Set-fnRemoveUsersFromGroups {
    #region - Import necessary configs and private functions #>
    $configHelper       = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $emailConfig        = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnEmailConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"                        -ErrorAction SilentlyContinue -Recurse)
    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($configHelper + $utility + $emailConfig)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }

    #endregion


    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $config = Get-fnConfig 
    $groupsToEmpty = (($config.groupsToEmpty) -replace '"', "") -split ","

    foreach($group in $groupsToEmpty){
        Write-Verbose "Checking group: $group"
        $members = Get-ADGroupMember -Identity $group
        
        foreach ($member in $members){
            write-host "Remove $member from $group"
            Remove-ADGroupMember -Identity $group -Members $member -Confirm:$False
        }
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Disable inactive users complete. It took $totalTime" 

}
$Global:today = Get-Date
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Set-fnRemoveUsersFromGroups -Verbose -InformationAction continue
Stop-Transcript

