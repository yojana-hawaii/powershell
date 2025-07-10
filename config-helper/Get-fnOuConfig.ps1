
function Get-fnOuConfig {

    $global = Get-Content "$PWD\config\ou-config.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $value = $keys[1] -replace ":", "="
        $conf += @{$keys[0]=$value}
    }
    return $conf
}


