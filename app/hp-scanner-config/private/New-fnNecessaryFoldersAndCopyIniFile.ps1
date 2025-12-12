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

            # if hash equal > no action needed > return
            $dst_sha256 = (Get-FileHash -Path $dst_path -Algorithm SHA256).hash
            if($hash.src_sha256 -eq $dst_sha256){
                return
            }
        }
        
        # if file not not exist or hash does not match > copy file
        Copy-Item -Path $hash.src -Destination $hash.dst
        return
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }


}