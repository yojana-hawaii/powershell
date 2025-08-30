function Get-fnDnsData{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$domain
    )
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting DNS Names"
        $dnsRecord = "_kerberos._tcp.$domain", "_ldap._tcp.$domain"
        $dnsData = foreach($dns in $dnsRecord){
            Resolve-DnsName -name   $dns -Type SRV
        }
        return @{
            Srv = $dnsData | Where-Object {$_.QueryType -eq 'SRV'} | Select-Object Target, NameTarget, Priority, Weight, Port, Name
            A = $dnsData | Where-Object {$_.QueryType -ne 'SRV'} | Select-Object Address,IPAddress,Name,Type,DataLength,TTL

        }
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
     continue
     }

}
