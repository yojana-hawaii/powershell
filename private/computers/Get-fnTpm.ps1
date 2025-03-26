
function Get-fnTpm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $tpm = Get-CimInstance -Class Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $computerName  |
                    Select-Object  @{
                        label = "TpmEnabled"
                        expression = {$_.IsEnabled_InitialValue}
                    }, 
                    @{
                        label = "TpmVersion"
                        expression = {($_.SpecVersion -split ",")[0]}
                    }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $tpm
}
