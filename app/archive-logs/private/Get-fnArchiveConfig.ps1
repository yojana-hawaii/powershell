function Get-fnArchiveConfig {
    [CmdletBinding()]
    param ()
    
    $global = Get-Content "$PWD\shared-ignore\config\archive.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}