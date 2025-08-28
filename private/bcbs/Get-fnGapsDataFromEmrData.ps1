function Get-fnGapsDataFromEmrData {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Object]$bcbsData,
        [System.Object]$emrData,
        [string]$bcbsSheet
    )

    switch ($bcbsSheet) {
        'bcs'               { $result = Get-fnBcbsBcsData -bcbsData $bcbsData -emrData $emrData; break }
        'bcs xcl'           { $result = Get-fnBcbsBcsXclData -bcbsData $bcbsData -emrData $emrData; break }
        'cbp'               { $result = Get-fnBcbsCbpData -bcbsData $bcbsData -emrData $emrData; break }
        'cis'               { $result = Get-fnBcbsCisData -bcbsData $bcbsData -emrData $emrData; break }
        'col'               { $result = Get-fnBcbsColData -bcbsData $bcbsData -emrData $emrData; break }
        'col xcl'           { $result = Get-fnBcbsColXclData -bcbsData $bcbsData -emrData $emrData; break }
        'gsd hba1c le9'     { $result = Get-fnBcbsHga1cData -bcbsData $bcbsData -emrData $emrData; break }
        'gsd hba1c lt8'     { $result = Get-fnBcbsHga1cData -bcbsData $bcbsData -emrData $emrData; break }
        'w30-15'            { $result = Get-fnBcbsWccData -bcbsData $bcbsData -emrData $emrData; break }
        'wcv 3-21'          { $result = Get-fnBcbsWcvData -bcbsData $bcbsData -emrData $emrData; break }
        Default             { $result = $null }
    }
    return $result
}