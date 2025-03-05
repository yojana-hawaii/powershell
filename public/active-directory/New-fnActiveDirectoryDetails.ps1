
set-location "\\fileserver\it\apps\powershell"



function New-fnActiveDirectoryDetails{
    [CmdletBinding()]
    param (
    )

    
    #region - Import necessary configs and private functions #>
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnConfig.ps1"                          -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\active-directory\*.ps1"               -ErrorAction SilentlyContinue -Recurse)
    $storedProcedure    = @(Get-ChildItem -Path "$PWD\stored-procedure\active-directory\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $sqlConection       = @(Get-ChildItem -Path "$PWD\stored-procedure\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"
    #import all function
    foreach ($import in @($configHelper + $private + $public + $storedProcedure + $utility + $sqlConection)){
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


    $ActiveDirectoryData = Get-fnActiveDirectory -Verbose
        
    foreach($data in $ActiveDirectoryData.GetEnumerator()){
        Add-spActiveDirectory -ActiveDirectory $data -Verbose
    }
    
    $organizationalUnits = Get-fnOrganizationalUnit -Verbose
    
    foreach($ou in $organizationalUnits)
    {
        Add-spOrganizationalUnit -organizational_unit $ou -Verbose
        foreach($acl in $ou.ExtendedAcl){
            Add-spOrganizationalUnitAcl -acl $acl -guid $ou.ObjectGuid
        }
    }

    
    $totalTime = Stop-Timer -Start $startTimer
    Write-Information "$($MyInvocation.MyCommand.Name): Active Diretory details complete. It took $totalTime" 

}


$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "MM-dd-yyyy"

Start-Transcript -Path "$pwd\log\$($MyInvocation.MyCommand.Name)_$mmddyyyy.txt" -Append
New-fnComputerDetails  -Verbose -InformationAction Continue
Stop-Transcript