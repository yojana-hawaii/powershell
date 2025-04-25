
function Get-fnMissingSlipConfig {

    $global = Get-Content "$PWD\config\missingslip.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}


