function Sync-ADToSql {
    [CmdletBinding()]
    param (
        [int]$DeltaHours = 48,
        [switch]$FullSync
    )
    
    $dateFilter = (Get-Date).AddHours(-$DeltaHours)
    $filter = if ($FullSync) { "*" } else { "whenChanged -gt '$dateFilter'" }

    # --- Sync Groups & Members ---
    $groups = Get-ADData -Type Group -Filter $filter -Properties whenChanged, whenCreated, Description, mail
    
    foreach ($grp in $groups) {
        # 1. Update Group Meta
        $grpParams = @{
            sAMAccountName = $grp.sAMAccountName
            Description    = $grp.Description
            ModifiedDate   = $grp.whenChanged
            # ... add other fields
        }
        Invoke-ADSqlStoredProcedure -StoredProcedure "dbo.spAdGroups" -Parameters $grpParams

        # 2. Update Members
        Get-ADGroupMember -Identity $grp.DistinguishedName -ErrorAction SilentlyContinue | ForEach-Object {
            $memParams = @{
                GroupSamAccountName = $grp.sAMAccountName
                Username            = $_.sAMAccountName
                ObjectClass         = $_.objectClass
            }
            Invoke-ADSqlStoredProcedure -StoredProcedure "dbo.spAdGroupMembers" -Parameters $memParams
        }
    }
    
    # --- Sync Computers ---
    # Fetching with specific properties is much faster than -Properties *
    $compProps = @('Enabled', 'CanonicalName', 'OperatingSystem', 'whenCreated', 'whenChanged', 'msLAPS_ExpirationTime', 'userAccountControl')
    $computers = Get-ADData -Type Computer -Filter $filter -Properties $compProps
    
    foreach ($comp in $computers) {
        $data = ConvertTo-SqlComputerObject -AdObject $comp
        Invoke-ADSqlStoredProcedure -StoredProcedure "dbo.spAdComputers" -Parameters ($data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object -Begin {$h=@{}} -Process {$h[$_] = $data.$_} -End {$h})
    }
}
