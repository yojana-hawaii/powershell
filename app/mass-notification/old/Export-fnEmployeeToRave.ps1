function Export-fnEmployeeToRave {
    Write-Information "$($MyInvocation.MyCommand.Name): Import necessary private functions & config helpers in "
    #region - Import necessary configs & utility functions #>
    Write-Verbose "Initialize private functions & config helpers in Export-fnEmployeeToRave.ps1"
    $private    = @(Get-ChildItem -Path "$PWD\app\mass-notification\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"  -ErrorAction SilentlyContinue -Recurse)

    foreach ($import in @($private + $utility)){
        try{
            . $import.Fullname
            Write-Information "importing $($import.Fullname)"
        } catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }
        
    }
    Remove-Variable import, utility, private, sqlConn, config, emailConf
    #endregion

    $rave = Get-fnMassNotificationConfig

    Write-Verbose "Strip `" (double quote). Pull path from config file adds double quotes everywhere"
    $username = ($rave.rave_username) -replace '"', ""
    $password = ($rave.rave_password) -replace '"', ""
    $sourceFile = (Join-Path -Path $rave.employeeFilepath -ChildPath $rave.employeeSourceFilename) -replace '"',""
    $destinationUrl = ($rave.rave_destinationurl) -replace '"', ""


    $webCredential = New-Object System.Net.NetworkCredential($username, $password)
    
    if (Test-Path -Path $sourceFile){
        Write-Verbose "Source path: File exists"
    
        try {
            Write-Verbose "Uploading file $sourceFile  to $destinationUrl $username $password"
            $webclient = New-Object System.Net.WebClient
            $webClient.Credentials = $webCredential
            # $webClient.UploadFile($destinationUrl, 'PUT', $sourceFile)
            Write-Verbose "Rave upload Success"
        } catch {
            Write-Warning "Rave upload failed: $($_.Exception.Message) "
        }
    
    } else {
        Write-Warning "Source file cannot be found: $($_.Exception.Message)"
    }
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
Export-fnEmployeeToRave -Verbose -InformationAction continue
Stop-Transcript