function Get-fnDentrixConfig {

    $global = Get-Content "$PWD\shared-ignore\config\dentrix.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}


