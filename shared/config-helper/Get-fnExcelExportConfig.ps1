function Get-fnExcelExportConfig{
    [CmdletBinding()]
    param ()
    
    $global = Get-Content "$PWD\shared-ignore\config\excel-export.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}