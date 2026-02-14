function ConvertTo-SqlComputerObject {
    param ($AdObject)
    
    # Pre-fetch Bitlocker info to avoid redundant calls inside Select-Object
    $bitlocker = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $AdObject.DistinguishedName -Properties whenCreated | 
                 Sort-Object whenCreated -Descending | Select-Object -First 1

    [PSCustomObject]@{
        ComputerName           = $AdObject.Name
        Enabled                = [int]$AdObject.Enabled
        HasBitlocker           = [int]($null -ne $bitlocker)
        DistinguishedName      = $AdObject.DistinguishedName
        OU                     = $AdObject.CanonicalName
        sAMAccountName         = $AdObject.sAMAccountName
        OperatingSystem        = $AdObject.OperatingSystem
        CreatedDate            = $AdObject.whenCreated
        ModifiedDate           = $AdObject.whenChanged
        BitLockerPasswordDate  = $bitlocker.whenCreated
        LapsExpirationDate     = if ($AdObject.msLAPS_ExpirationTime) { [datetime]::FromFileTime($AdObject.msLAPS_ExpirationTime) } else { $null }
        UserAccountControl     = $AdObject.userAccountControl
    }
}
