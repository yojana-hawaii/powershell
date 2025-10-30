set-location "\\fileserver\it\apps\powershell"
function Get-fnVendorsAndStudents {
    #region - Import necessary configs and private functions #>
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)    
    $private    = @(Get-ChildItem -Path "$PWD\app\users\students-vendors\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $excel      = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnExcelExportConfig.ps1" -ErrorAction SilentlyContinue -Recurse)

    Write-Information "Read public, private & shared functions, stored procedures and config helpers"

    foreach ($import in @($utility + $sqlConn + $config + $emailConf + $private + $excel)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    Remove-Variable import, utility, sqlConn, config, emailConf, private,excel
    #endregion

    $startTimer = Start-Timer
    Write-Verbose "$($MyInvocation.MyCommand.Name): start." 

    $today = Get-Date -Format "yyyy-MM-dd"
    $exportConf = Get-fnExcelExportConfig
    $root = ($exportConf.studentAndVendors) -replace '"', ""
    $extension = ($exportConf.extension) -replace '"', ""
    $file = "$today vendors & students list.$extension"
    $path = Join-Path $root -ChildPath $file

    try { 
        $data = Invoke-spGetVendorsAndStudents
        $data | 
            Select-Object Type, Username, @{
                label = "Name"
                expression = {$_.DisplayName}
            }, @{
                label="Account Created"
                expression = {Get-Date $_.CreatedDate -Format "MM/dd/yyyy"}
            }, @{
                label="last logon"
                expression={Get-Date $_.LastLogonDate -Format "MM/dd/yyyy"}
            }, AccountActive, Manager, EmailAddress, @{
                label="Phone"
                expression={$_.OfficePhone}
            }, Company, Title, Maybe |
            Export-Excel -Path $path -AutoSize
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

    $email = Initialize-fnEmailConfig
    Get-fnEmailConfig_VendorsAndStudents -email $email
    Send-fnEmail -email $email

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
$InformationPreference = "continue"
Get-fnVendorsAndStudents -Verbose -InformationAction continue
Stop-Transcript