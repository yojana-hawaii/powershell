function Get-fnProviderFileName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$provname
    )

    # file name
    if($provname -eq "unknown") {
        return "$($orderHash.unknownProvider).xlsx"
    } else {
        $provider = ($provname.ToLower() )-split ","
        $first = ($provider[1].Trim()).Replace(" ","-")
        $last = ($provider[0].Trim()).Replace(" ","-")
        return "$first-$last.xlsx"
    }
}
