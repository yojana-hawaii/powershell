function Split-fnFilterByString {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param,
        [string]$filterStr
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): filter column by string $filterStr"
    # magic string has column to filter and value to separate
    $column = (($param.$filterStr)[0]).ToString()
    $value  = (($param.$filterStr)[1]).ToString()
    
    # hashtable property has magic string with Data appended
    $propertyName = "$($filterStr)Data"
    
    $temp = $param.sourceData
    $param.sourceData = ""
    
    # separated data in new property and keep the rest in SourceData Property
    $param.$propertyName  = $temp | Where-Object {$_.$column -eq $value}
    $param.sourceData = $temp | Where-Object {$_.$column -ne $value}
}