
set-location "\\fileserver\it\apps\powershell"

function fnLocal_InsertListOfComputers($computers){
    $total = $computers.count 
    $cnt = 1
    foreach($computer in $computers){
        Write-Information "Inserting $cnt of $total computers, $($computer.sAMAccountName)"
        Invoke-spAdComputer -computer $computer
        $cnt++
    }
}
function fnLocal_InsertListOfUsers($users){
    $total = $users.count
    $cnt = 1
    foreach($user in $users){
        Write-Information "Inserting $cnt of $total users, $($user.sAMAccountName)"
        # $user
        Invoke-spAdUser -user $user
        $cnt++
    }
}
function Get-fnActiveDirectoryDetails{
    [CmdletBinding()]
    param (
    )
    #region - Import necessary configs and private functions #>
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\active-directory\*.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\active-directory\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"                        -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"         -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($configHelper + $private + $storedProcedure + $utility + $sqlConection)){
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


    #region Users
    # Active
    $activeUsers = Get-fnAdUsers -enabled $true
    fnLocal_InsertListOfUsers -users $activeUsers 
    # Inactive 
    $inactiveUsers = Get-fnAdUsers -enabled $false
    fnLocal_InsertListOfUsers -users $inactiveUsers 
    
    #endregion
    
    #region Computers
    ## Import in 3 groups. server, Active non servers and Inactive non server - too many computers in AD

    # Servers
    $servers = Get-fnAdComputers -enabled $false -server $true
    fnLocal_InsertListOfComputers -computers $servers
    # Active
    $activeComputers = Get-fnAdComputers -enabled $true
    fnLocal_InsertListOfComputers -computers $activeComputers
    # Inactive
    $inactiveComputers = Get-fnAdComputers -enabled $false
    fnLocal_InsertListOfComputers -computers $inactiveComputers
    #endregion

    # First run or all groups deltaChangeHours = 0 (50 years)
    # 50 after that -> changes in last 50 hours 
    $deltaChange = 48

    $groups = Get-fnAdGroups -deltaChangeHours $deltaChange
    $totalGroups = $groups.count
    $count = 1
    foreach($group in $groups){
        Write-Information "inserting $count of $totalGroups : $($group.sAMAccountName)"
        Invoke-spAdGroup -group $group
        $count++
    }
     

    $ActiveDirectoryData = Get-fnActiveDirectory -Verbose  
    foreach($data in $ActiveDirectoryData.GetEnumerator()){
        Invoke-spActiveDirectory -ActiveDirectory $data -Verbose
    }
    
    $organizationalUnits = Get-fnOrganizationalUnit -Verbose
    foreach($ou in $organizationalUnits)
    {
        Invoke-spOrganizationalUnit -organizational_unit $ou -Verbose
        foreach($acl in $ou.ExtendedAcl){
            Invoke-spOrganizationalUnitAcl -acl $acl -guid $ou.ObjectGuid
        }
    }
    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Active Diretory details complete. It took $totalTime" 

}


$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "MM-dd-yyyy"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$mmddyyyy.txt" -Append
Get-fnActiveDirectoryDetails  -Verbose -InformationAction Continue
Stop-Transcript