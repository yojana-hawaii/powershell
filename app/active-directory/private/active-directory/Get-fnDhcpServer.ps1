function Get-fnDhcpServer {
    [CmdletBinding()]
    param()
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting DHCP Names"
        return @((Get-DhcpServerInDC).dnsname)
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
         continue
     }
}
# Get-fnDhcpServer -Verbose
