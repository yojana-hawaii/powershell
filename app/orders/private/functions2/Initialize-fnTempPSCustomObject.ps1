function Initialize-fnTempPSCustomObject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$type,
        [string]$unknownProvider,
        [string]$provname
    )

    if($type -eq "Detail"){
        # file name
        if($row.Name -eq "unknown") {
            $filename = "$unknownProvider.xlsx"
        } else {
            $provider = ($provname.ToLower() )-split ","
            $first = ($provider[1].Trim()).Replace(" ","-")
            $last = ($provider[0].Trim()).Replace(" ","-")
            $fileName = "$first-$last.xlsx"
        }

        return [PSCustomObject]@{
                Name  = $row.Name
                Consult = @()
                "Internal-Consult" = @()
                Lab = @()
                Imaging = @()
                "Internal-Imaging" = @()
                Procedure = @()
                Other = @()
                Total = $row.Count
                FilePath = Join-Path -Path $param.export -ChildPath $fileName
            }
    }
    
    return [PSCustomObject]@{
                Name  = $row.Name
                Consult = 0
                "Internal-Consult" = 0
                Lab = 0
                Imaging = 0
                "Internal-Imaging" = 0
                Procedure = 0
                Other = 0
                Total = $row.Count
                FilePath = ""
            }
}