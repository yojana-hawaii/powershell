
function Get-fnDomainControllerReplication {
    [CmdletBinding()]
    param(
        [CmdletBinding()]    
        [Parameter()]
        [array] $server    
    )
    
    try {
        Write-Verbose "Getting Domain Controller Replication Details"
        foreach ($dc in $server){
            Get-ADReplicationPartnerMetadata -target $dc | 
                Select-Object Server, `
                @{Name='Partner'; Expression={(Resolve-DnsName -Name $_.PartnerAddress).NameHost}},
                PartnerType, `
                LastReplicationAttempt, LastReplicationResult, LastReplicationSuccess, LastChangeUsn,`
                @{Name="LastReplSuccess"; Expression={$_.LastReplicationResult -eq 0}},`
                TwoWaySync, ScheduledSync, SyncOnStartup, DisableScheduledSync, CompressChanges,`
                UsnFilter,`
                ConsecutiveReplicationFailures

        }
        
    } catch {
        Write-Warning "Get-fnDomainControllerReplication failed: $($_.Exception.Message) "
        continue
    }
}

