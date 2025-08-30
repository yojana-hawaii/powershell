function Get-fnSubets {
    [CmdletBinding()]
    param ()

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting subnets"

        $subnets = Get-ADReplicationSubnet -Filter * -Properties * | Select-Object Name, DisplayName, Description, Site, ProtectionFromAccientalDeletion, Created, Modified, Deleted
        return $subnets
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }
}
# Get-fnSubets