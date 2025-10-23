function Get-fnRebootConfig {
    $global = Get-Content "$PWD\shared-ignore\config\reboot.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $value = $keys[1] -replace ":", "="
        $conf += @{$keys[0]=$value}
    }
    return $conf
}