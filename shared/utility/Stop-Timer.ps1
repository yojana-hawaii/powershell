function Stop-Timer {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [System.Diagnostics.Stopwatch] $Start,
        [Parameter()]
        [switch] $Continue
    )


    $timeToExecute = "$($Start.Elapsed.Days) days, $($Start.Elapsed.Hours) hours, $($Start.Elapsed.Minutes) minutes, $($Start.Elapsed.Seconds) seconds, $($Start.Elapsed.Milliseconds) milliseconds"

    if(-not $continue){
        $Start.Stop()
    }
    return $timeToExecute

}