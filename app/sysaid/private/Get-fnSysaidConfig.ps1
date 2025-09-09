
function Get-fnSysaidConfig {

    $global = Get-Content "$PWD\shared-ignore\config\sysaid.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}


