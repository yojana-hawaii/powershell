function Get-fnSqlConfig {
    
    $global = Get-Content "$PWD\shared-ignore\config\sql.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}