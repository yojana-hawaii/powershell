function Get-fnPeerReviewObject {
    Write-Information "$($MyInvocation.MyCommand.Name): create peer review hash object"  

    $conf = Get-fnAthenaConfig
    $q = Get-fnCalendarQuarter -ThisQuarterOrLastQuarter "LastQuarter"
    return @{
        uds5Filtered = $conf.uds5Filtered  -replace '"',""
        udsInclusion = $conf.udsInclusion  -replace '"',""
        sourceFileValidDays = 60
        randomVisitPerProvider = 5

        QuarterYear = $q.Year
        QuarterNumber = $q.QuarterNumber
        QuarterStart = $q.QuarterStart
        QuarterEnd = $q.QuarterEnd

        QualifyingVisits = ""
        RandomVisits = ""

        ExportPath = $conf.exportPath -replace '"', ""
    }
}