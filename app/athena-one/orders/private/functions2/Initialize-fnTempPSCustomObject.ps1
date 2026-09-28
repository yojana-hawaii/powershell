function Initialize-fnTempPSCustomObject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$type,
        [string]$provname
    )

    if($type -eq "Detail"){
        $fileName = Get-fnProviderFileName -provname $provname
        return [PSCustomObject]@{
                Name  = $provname
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
                Name  = $provname
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