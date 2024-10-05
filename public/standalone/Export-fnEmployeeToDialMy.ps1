# import config necessary   
function Get-fnDialMyConfig {
    [CmdletBinding()]
    param()

    $global = Get-Content "$PWD\config\standalone.conf"
    $conf = @()

    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}

# import private standalone functions
$standalone = @(Get-ChildItem -Path "$PWD\private\standalone\*.ps1"     -ErrorAction SilentlyContinue -Recurse)
$org        = @(Get-ChildItem -Path "$PWD\private\organization-specific\*.ps1"     -ErrorAction SilentlyContinue -Recurse)
foreach ($import in @($standalone + $org)){
    try{
        . $import.Fullname
        Write-Verbose "importing $($import.Fullname)" 
    } catch {
        Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
        $true
    }
    
}

function Export-fnEmployeeToDialMy {
    [CmdletBinding()]
    param()
    <# Get data from config file. Strip " (double quote). Pulling path from config file adds double quotes everywhere #>
   
    $dialMy = Get-fnDialMyConfig
    $sourceFile          = (Join-Path -Path $dialMy.filepath -ChildPath $dialMy.sourceFilename) -replace '"',""
    $dialMyCsv           = (Join-Path -Path $dialMy.filepath -ChildPath $dialMy.dialMyCsv) -replace '"',""
    $activeDirectoryCsv  = (Join-Path -Path $dialMy.filepath -ChildPath $dialMy.activeDirectoryCsv) -replace '"',""
    $azureDirectoryCsv   = (Join-Path -Path $dialMy.filepath -ChildPath $dialMy.azureDirectoryCsv) -replace '"',""
    $validateCsv         = (Join-Path -Path $dialMy.filepath -ChildPath $dialMy.validateCsv) -replace '"',""
    $org2                = ($dialMy.organization2) -replace '"',""
   
    $employees = Convert-fnCsvToEmployee -sourceFile $sourceFile -org2 $org2
    
    $employees | Select-Object Last,First,cellPhone,dialGroup | Export-csv -Path $dialMyCsv -NoTypeInformation
    $employees | Select-Object Last,First,staffEmail,managerEmail,location,department,jobtitle,orgGroup | Export-csv -Path $validateCsv -NoTypeInformation
    $employees | Where-Object {$_.department -ne $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $activeDirectoryCsv -NoTypeInformation
    $employees | Where-Object {$_.department -eq $org2} | Select-Object Last,First,staffEmail,manager,managerEmail,location,department,jobtitle | Export-csv -Path $azureDirectoryCsv -NoTypeInformation
        
}

Export-fnEmployeeToDialMy -Verbose