function Get-fnProductivityConfig {
    [CmdletBinding()]
    param()

    $global = Get-Content "$PWD\shared-ignore\config\productivity.conf"
    $conf = @()

    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}