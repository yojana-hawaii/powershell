function fnLocal_Tpm($tpm){
    return ($tpm -split ",")[0]
}

function Get-fnTpm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name): $($computerName)"
    try {
        $tpm = Get-WmiObject -Class Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $computerName -Authentication PacketPrivacy |
                    Select-Object  @{
                        label = "TpmEnabled"
                        expression = {$_.IsEnabled_InitialValue}
                    }, 
                    @{
                        label = "TpmVersion"
                        expression = {fnLocal_Tpm($_.SpecVersion)}
                    }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
    return $tpm
}
