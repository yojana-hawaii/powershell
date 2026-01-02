function Get-fnCalendarQuarter {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ThisQuarterOrLastQuarter = "ThisQuarter" 
    )
    # today midnight
    $today = [datetime]::Today

    $currentQuarterStart = $today.AddMonths( -($today.Month - 1) % 3).AddDays( -($today.Day - 1))
    
    if($ThisQuarterOrLastQuarter -eq "LastQuarter"){
        $lastQuarterStart = $currentQuarterStart.Addmonths(-3)
        $start = $lastQuarterStart
    } else {
        $start = $currentQuarterStart
    }

    $quarter = [Math]::Ceiling($start.Month / 3) # divide by 3 and round up.
    $year = $start.Year
    $lastDay = [datetime]::DaysInMonth([int]$year.ToString(), [int]($quarter* 3)) 
    $end = ($quarter * 3).ToString() + "/$lastDay/" + $year.ToString() 

    return @{
        Year = $year
        QuarterNumber = $quarter
        QuarterStart = Get-Date $start -Format "MM/dd/yyyy"
        QuarterEnd = $end
    }
}