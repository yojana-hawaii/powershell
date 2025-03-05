function Get-fnRodc {
    [CmdletBinding()]
    param()
    

    try {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting RODC Names"
        return @((Get-ADDomainController -Filter {isreadonly -eq $true}).hostname)
     } catch {
         Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
         continue
     }
}
# Get-fnRodc -Verbose
