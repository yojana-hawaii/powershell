
set-location "\\fileserver\it\apps\powershell"

function Get-fnActiveDirectoryDetails{
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    $private    = @(Get-ChildItem -Path "$PWD\app\active-directory\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    
    foreach ($import in @($utility + $private + $sqlConn + $config)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."  

    #region Users
    # Active
    $activeUsers = Get-fnAdUsers -enabled $true
    Push-fnInsertAdUsers -users $activeUsers 
    # Inactive 
    $inactiveUsers = Get-fnAdUsers -enabled $false
    Push-fnInsertAdUsers -users $inactiveUsers 
    
    #endregion
    
    #region Computers
    ## Import in 3 groups. server, Active non servers and Inactive non server - too many computers in AD

    # Servers
    $servers = Get-fnAdComputers -enabled $false -server $true
    Push-fnInsertAdComputers -computers $servers
    # Active
    $activeComputers = Get-fnAdComputers -enabled $true
    Push-fnInsertAdComputers -computers $activeComputers
    # Inactive
    $inactiveComputers = Get-fnAdComputers -enabled $false
    Push-fnInsertAdComputers -computers $inactiveComputers
    #endregion


    #region Groups
    # First run or all groups deltaChangeHours = 0 (50 years)
    # 50 after that -> changes in last 50 hours 
    $deltaChange = 48

    # --- Process Groups ---
    $groups = Get-fnAdGroups -deltaChangeHours $deltaChange
    $totalGroups = @($groups).Count # Wrapping in @() ensures .Count works even for 1 result
    
    if ($totalGroups -gt 0) {
        $count = 1
        foreach($group in $groups){
            Write-Progress -Activity "Inserting Groups to DB" -Status "Group $count of $totalGroups" -PercentComplete (($count / $totalGroups) * 100)
            
            # Write-Information for logging
            Write-Information "Processing: $($group.sAMAccountName)"
            
            Invoke-spAdGroup -group $group
            $count++
        }
    } else {
        Write-Warning "No groups found to update in the last $deltaChange hours."
    }
    
    # --- Process Members ---
    $groupMembers = Get-fnAdGroupMembers -deltaChangeHours $deltaChange
    $totalGm = @($groupMembers).Count
    
    if ($totalGm -gt 0) {
        $countGm = 1
        foreach($gm in $groupMembers){
            Write-Progress -Activity "Inserting Members to DB" -Status "User $countGm of $totalGm" -PercentComplete (($countGm / $totalGm) * 100)
            
            # Note: Corrected property name case to match your previous PSCustomObject (GroupSamAccountName)
            Write-Information "Inserting member: $($gm.Username) for group: $($gm.GroupSamAccountName)"
    
            Invoke-spAdGroupMembers -groupMember $gm
            $countGm++
        }
    }
    #endregion
     
    
    $ActiveDirectoryData = Get-fnActiveDirectory -Verbose  
    foreach($data in $ActiveDirectoryData.GetEnumerator()){
        Invoke-spActiveDirectory -ActiveDirectory $data -Verbose
    }
    
    #region OU
    $organizationalUnits = Get-fnOrganizationalUnit -Verbose
    foreach($ou in $organizationalUnits)
    {
        Invoke-spOrganizationalUnit -organizational_unit $ou -Verbose
        foreach($acl in $ou.ExtendedAcl){
            Invoke-spOrganizationalUnitAcl -acl $acl -guid $ou.ObjectGuid
        }
    }
    #endregion

    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Active Diretory details complete. It took $totalTime" 

}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Get-fnActiveDirectoryDetails -Verbose -InformationAction continue
Stop-Transcript
