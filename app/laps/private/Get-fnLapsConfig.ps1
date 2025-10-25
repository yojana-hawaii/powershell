function Get-fnLapsConfig {

    $global = Get-Content "$PWD\shared-ignore\config\laps.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}


