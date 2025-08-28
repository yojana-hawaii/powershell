function Export-fnHumanAiValidation {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$insuranceAi,
        [string]$demographicsAi,
        [string]$noMatchAi
    )
    Invoke-fnGetPartialMatchForValidation | 
        Sort-Object -property  @{Expression='patient-next-appt';Descending=$true}, 
                @{Expression='patient-last-seen';Descending=$true} | 
        Export-Csv -Path $demographicsAi -NoTypeInformation

    Invoke-fnGetInsuranceMismatchForValidation |
        Sort-Object -property  @{Expression='matchingcriteria';Descending=$true}| 
        Export-Csv -Path $insuranceAi -NoTypeInformation

    Invoke-fnGetNoMatchForValidation |
        Export-Csv -Path $noMatchAi -NoTypeInformation
}