function Split-fnFilterByDate {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param,
        [string]$filterStr
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): filter column by date $filterStr"

    $today = Get-Date

    # magic string has column to filter by date
    $column = ($param.$filterStr)[0]
    $operator = ($param.$filterStr)[1]

    # magic string to generate hashtable key in turn 
    $propNameFromMagicString = "$($filterStr)Days"
    $orderTypeDaysHash = $param.$propNameFromMagicString

    # hashtable property has magic string with Data appended
    $propertyName = "$($filterStr)Data"
    
    $temp = $param.sourceData
    
    $param.sourceData = @()
    $param.$propertyName = @()
    
    # separated data in new property and keep the rest in SourceData Property
    foreach($row in $temp){
        # if filter column has no date, too bad it is staying on the list
        if($null -eq $row.$column -or $row.$column -eq ""){
            $param.sourceData += $row
            continue
        }

        # if there is date then calculate the days since 
        $actualDaysSince = (New-TimeSpan -Start $row.$column -End $today  ).Days 
        # get the days for the specific order type
        $goalCutoffDays = $orderTypeDaysHash[$row.OrderType]
        # if days for the order type not defined, then stick with default
        if($null -eq $goalCutoffDays) {$goalCutoffDays = $orderTypeDaysHash["default"]}

        # if $actualDays > $goalDays -> need to follow up 
        # alarm goal for lab 7, if more than 8 days, need to follow up
        # last update goal for lab is 14 days, if more than 15 days, need to follow up
        if($operator -eq "-gt"  -and $actualDaysSince -gt $goalCutoffDays ){
            $param.sourceData += $row
            continue
        }

        # if $actualDays < $goalDays -> need to follow up
        # expire goal for lab is 180 days, if less than 180 days > need to folow up
        if($operator -eq "-lt" -and $actualDaysSince -lt $goalCutoffDays ){
            $param.sourceData += $row
            continue
        }

        # if filter date less than days in hashtable, remove from the list
        $param.$propertyName += $row
    }
}