function Get-fnUserProfileAndPushHpScannerConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$hash
    )
    Write-Information "$($MyInvocation.MyCommand.Name):  "

    $hash.userDir = "$($hash.userDirPrefix)$($hash.compName)$($hash.userDirSuffix)"

    # guard clause if userDir is not accessible
    if(-not (Test-Path -Path $hash.userDir)){
        Write-Warning "$userDir not accessible."
        return
    }
    

    #try cath when there is possibility of exception
    try { 
        $userProfiles = Get-ChildItem($hash.userDir)

        foreach($userProfile in $userProfiles){
            if($hash.excludeProfiles -contains [string]$userProfile){
                Write-Verbose "Excluding user profile $userProfile"
                continue
            } else {
                Write-Verbose "Do something to $userProfile"

                $hash.src = $hash.s3_src_ini_file
                $hash.src_sha256 = $hash.s3_sha256
                $hash.dst = "$($hash.userDir)$userProfile$($hash.hp_path)$($hash.hp_s3)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash
                
                $hash.dst = "$($hash.userDir)$userProfile$($hash.hp_path)$($hash.hp_alt_path)$($hash.hp_s3)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash

                $hash.src = $hash.s4_src_ini_file
                $hash.src_sha256 = $hash.s4_sha256
                $hash.dst = "$($hash.userDir)$userProfile$($hash.hp_path)$($hash.hp_alt_path)$($hash.hp_s4)"
                New-fnNecessaryFoldersAndCopyIniFile -hash $hash
            }
        }

    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return

}