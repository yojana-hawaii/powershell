function Get-ADData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('User', 'Computer', 'Group', 'GroupMember')]
        [string]$Type,
        [string]$Filter = '*',
        [string[]]$Properties = @()
    )
    process {
        try {
            $cmd = "Get-AD$Type"
            $params = @{
                Filter     = $Filter
                Properties = $Properties
                ErrorAction = 'Stop'
            }
            Write-Verbose "Fetching $Type data with filter: $Filter"
            & $cmd @params
        }
        catch {
            Write-Error "Failed to fetch $Type data: $($_.Exception.Message)"
        }
    }
}
