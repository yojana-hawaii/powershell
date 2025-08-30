function Get-fnReplicationSiteLinks {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting Replication Site Links"
        return Get-ADReplicationSiteLink -Filter * -Properties * | 
            Select-Object Name, Cost, ReplicationFrequencyInMinutes, ReplInterval, ReplicationSchedule, `
                Created, Modified, Deleted, InterSiteTransportProrocol, DistinguishedName, ProtectedFromAccidentalDeletion

     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }


}

# Get-fnSiteLinks -Verbose