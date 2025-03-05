

function Get-fnGlobalCatalog {
    [CmdletBinding()]
    param()
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting global catalog server Names"
        return @((Get-ADDomainController -Filter {IsGlobalCatalog -eq $true}).Hostname)

     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }
}
# Get-fnGlobalCatalog -Verbose

