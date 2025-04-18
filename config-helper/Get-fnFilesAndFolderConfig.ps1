function Get-fnFilesAndFolderConfig {
    [CmdletBinding()]
    param ()
    
    $global = Get-Content "$PWD\config\files-and-folders.conf"
    
    $conf = @()
    
    $global | ForEach-Object {
        $keys = $_ -split "="
        $conf += @{$keys[0]=$keys[1]}
    }
    return $conf
}