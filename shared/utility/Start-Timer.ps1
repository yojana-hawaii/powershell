function Start-Timer {
    [CmdletBinding()]
    param()
    [System.Diagnostics.Stopwatch]::StartNew()
}