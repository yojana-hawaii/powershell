function Get-fnUserProfileAndPushHpScannerConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )
    Write-Information "$($MyInvocation.MyCommand.Name):  "

    $hash.srcUserDir = "$($hash.srcUserDirPrefix)$($hash.srcCompName)$($hash.srcUserDirSuffix)"

    # guard clause if userDir is not accessible
    if(-not (Test-Path -Path $hash.srcUserDir)){
        Write-Warning "$userDir not accessible."
        return
    }
    

    # try-cath when there is possibility of exception
    try { 
        $userProfiles = Get-ChildItem($hash.srcUserDir)

        foreach($userProfile in $userProfiles){
            if($hash.excludeProfiles -contains [string]$userProfile){
                Write-Verbose "Excluding user profile $userProfile"
                continue
            } else {
                Write-Verbose "Do something to $userProfile"

                $hash.currentUser = $userProfile

                $hash.src = $hash.s3_src_ini_file
                $hash.src_modified_date = $hash.s3_modified_date
                
                $hash.dst = "$($hash.srcUserDir)$userProfile$($hash.srcHpPath)$($hash.srcHpS3)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash
                
                $hash.dst = "$($hash.srcUserDir)$userProfile$($hash.srcHpPath)$($hash.srcHpAltPath)$($hash.srcHpS3)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash
                
                $hash.src = $hash.s4_src_ini_file
                $hash.src_sha256 = $hash.s4_sha256
                $hash.src_modified_date = $hash.s4_modified_date
                $hash.dst = "$($hash.srcUserDir)$userProfile$($hash.srcHpPath)$($hash.srcHpAltPath)$($hash.srcHpS4)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash
            }
        }

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return

}