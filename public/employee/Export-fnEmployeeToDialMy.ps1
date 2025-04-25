function Export-fnEmployeeToDialMy {
    [CmdletBinding()]
    param()

    #region - Import necessary configs and private functions #>

    Write-Verbose "Initialize private functions & config helpers in Export-fnEmployeeToDialMy.ps1"
    $configHelper       = @(Get-ChildItem -Path "$PWD\config-helper\Get-fnEmployeeConfig.ps1"              -ErrorAction SilentlyContinue -Recurse)
    $private            = @(Get-ChildItem -Path "$PWD\private\employee\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $org                = @(Get-ChildItem -Path "$PWD\private\organization-specific\*.ps1"  -ErrorAction SilentlyContinue -Recurse)
    $utility            = @(Get-ChildItem -Path "$PWD\private\utility\*.ps1"  -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($configHelper + $private + $org + $utility)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    $import = $null
    #endregion

    Write-Verbose "Initialize config from employee config file."

    #region Initialize
    $config = Get-fnEmployeeConfig

    Write-Verbose "Strip `" (double quote). Pull path from config file adds double quotes everywhere"
    $sourceFile                     = (Join-Path -Path $config.employeeFilepath -ChildPath $config.employeeSourceFilename) -replace '"',""
    $additionalPhoneNumbersFile     = (Join-Path -Path $config.employeeFilepath -ChildPath $config.additionalPhoneNumbers) -replace '"',""
    $dialMyCsv                      = (Join-Path -Path $config.employeeFilepath -ChildPath $config.dialMyCsv) -replace '"',""
    $activeDirectoryCsv             = (Join-Path -Path $config.employeeFilepath -ChildPath $config.activeDirectoryCsv) -replace '"',""
    $azureDirectoryCsv              = (Join-Path -Path $config.employeeFilepath -ChildPath $config.azureDirectoryCsv) -replace '"',""
    $validateCsv                    = (Join-Path -Path $config.employeeFilepath -ChildPath $config.validateCsv) -replace '"',""
    $org2                           = ($config.organization2) -replace '"',""
    $sourceFileHeader               = ($config.sourceFileHeader) -replace '"',""
    #endregion

    $employees = Convert-fnCsvToEmployee -sourceFile $sourceFile -org2 $org2 -sourceFileHeader $sourceFileHeader
    $employees = Add-fnMissingPhoneNumbers -employees $employees -additionalPhoneNumbersFile $additionalPhoneNumbersFile

    $employees | Select-Object Last,First,cellPhone,dialGroup | Export-csv -Path $dialMyCsv -NoTypeInformation
    $employees | Select-Object Last,First,hrEmail,cellPhone,staffEmail,manager,managerEmail,location,department,jobtitle,orgGroup | Export-csv -Path $validateCsv -NoTypeInformation
    $employees | Where-Object {$_.department -ne $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $activeDirectoryCsv -NoTypeInformation
    $employees | Where-Object {$_.department -eq $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $azureDirectoryCsv -NoTypeInformation
        
}

$Global:today = $null
$today = Get-Date
$mmddyyyy = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\log\Export-fnEmployeeToDialM_$mmddyyyy.txt" -Append
Export-fnEmployeeToDialMy  -Verbose -InformationAction Continue
Stop-Transcript
