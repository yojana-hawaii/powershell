function Get-fnMassNotificationConfig {
    [CmdletBinding()]
    param()

    $global = Get-Content "$PWD\shared-ignore\config\mass-notification.conf"
    $conf = @()

    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}