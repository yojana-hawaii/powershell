function New-fnNecessaryFoldersAndCopyIniFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )

    
    try { 
        # create necessary folder
        if (-Not(Test-Path $hash.dst)){
            New-Item -ItemType Directory -Force $hash.dst
        }

        # if file exists, compare hash
        $dst_path = Join-Path $hash.dst -ChildPath "ScanApp.ini"
        if(Test-Path $dst_path){
            # if hash equal > no action needed > return > hash does not matter
            # each file is unique has username is different
            # try file last modified
            $modified  = (Get-ChildItem -Path $dst_path).LastWriteTime
            $timeSpan = New-TimeSpan -End $modified -Start $hash.src_modified_date
            if ($timeSpan.Days -gt 1){
                return
            }

            # if newUser text appears in the ini file exists then delete the file and start over
            $defaultUsernameExists = Select-String -Pattern $hash.default_username -Path $dst_path
            if($defaultUsernameExists){
                Remove-Item -Path $dst_path -Force
            }

            # ENABLE WHEN there is need to delete all INI file and start fresh
            # $profileExists = Select-String -Pattern $hash.scanner_profile_name -Path $dst_path
            # if($profileExists){
            #     Remove-Item -Path $dst_path -Force
            # }

            
            # if file not not exist or has been deleted > copy file
            Copy-Item -Path $hash.src -Destination $hash.dst
    
            # replace default_username with correct username
            (Get-Content -Path $dst_path) -replace ($hash.default_username, $hash.currentUser) | Set-Content -Path $dst_path
        }

        return
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }


}