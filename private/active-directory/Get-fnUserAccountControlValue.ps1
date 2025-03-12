function Get-fnUserAccountControlValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$userAccountControlFlag
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($userAccountControlFlag)"
    try {
        $value = ''
    switch($userAccountControlFlag){
        1 {$value = 'SCRIPT'; break}
        2 {$value = 'ACCOUNTDISABLE'; break}
        8 {$value = 'HOMEDIR_REQUIRED'; break}
        16 {$value = 'Locked-out'; break}
        32 {$value = 'Password-Not-Required'; break}
        64 {$value = 'Password-cant-change'; break}
        128 {$value = 'ENCRYPTED_TEXT_PWD_ALLOWED'; break}
        256 {$value = 'TEMP_DUPLICATE_ACCOUNT'; break}
        512 {$value = 'Normal-Account'; break}
        2048 {$value = 'Interdomain-Trust-Account'; break}
        4096 {$value = 'Workstation'; break}
        8192 {$value = 'Server'; break}
        65536 {$value = 'Password-dont-expire'; break}
        131072 {$value = 'MNS_LOGON_ACCOUNT'; break}
        262144 {$value = 'SMARTCARD_REQUIRED'; break}
        524288 {$value = 'TRUSTED_FOR_DELEGRATION'; break}
        104288 {$value = 'NOT_DELETGATED'; break}
        2097152 {$value = 'USES_DES_KEY_ONLY'; break}
        4194304 {$value = 'DONT_REQ_PREAUTH'; break}
        8288608 {$value = 'Password-Expired'; break}
        16777216 {$value = 'TRUSTED_TO_AUTH_FOR_DELEGATION'; break}
        67108864 {$value = 'PARTIAL_SECRETS_ACCOUNT'; break}

        Default {$value = $userAccountControlFlag}
    }
    return $value
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($userAccountControlFlag): $($_.Exception.Message)"
    }
}