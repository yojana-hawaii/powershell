
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
            Write-Verbose "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start."  



    #region Groups and Members and Users

    # --- Process Groups ---
    $groups = Get-fnAdGroups 
    Invoke-spAdGroups_Scd2 -groups $groups
    
    # --- Process Members ---
    $groupMembers = Get-fnAdGroupMembers 
    Invoke-spAdGroupMembers_Scd2 -groupMembers $groupMembers

    # --- Process Users ---
    $users = (Get-fnAdUsers) | Where-Object {$null -ne $_.CanonicalName }
    Invoke-spAdUsers_Scd2 -users $users

    #endregion

    #region Computers
    ## Import in 3 groups. server, Active non servers and Inactive non server - too many computers in AD

    # Active
    $activeComputers = Get-fnAdComputers -enabled $true
    Push-fnInsertAdComputers -computers $activeComputers
    # Inactive
    $inactiveComputers = Get-fnAdComputers -enabled $false
    Push-fnInsertAdComputers -computers $inactiveComputers
    # Servers
    $servers = Get-fnAdComputers -enabled $false -server $true
    Push-fnInsertAdComputers -computers $servers
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
