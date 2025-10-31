function fnLocal_InitializeTempPSCustomObject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Type
    )

    if($type -eq "Detail"){
        return [PSCustomObject]@{
                Name  = $row.Name
                Consult = @()
                "Internal-Consult" = @()
                Lab = @()
                Imaging = @()
                "Internal-Imaging" = @()
                Procedure = @()
                Other = @()
                Total = $row.Count
            }
    }
    
    return [PSCustomObject]@{
                Name  = $row.Name
                Consult = 0
                "Internal-Consult" = 0
                Lab = 0
                Imaging = 0
                "Internal-Imaging" = 0
                Procedure = 0
                Other = 0
                Total = $row.Count
            }
}
function Get-fnGroupedSummary {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param,
        [string]$filterStr,
        [string]$pivotDataType
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Generating executive summary by $filterStr $pivotDataType"
    $propertyAppend = if($pivotDataType -eq "count") {"Summary"} else {"Detail"}
    $propertyName = "$($filterStr)$propertyAppend"
    $propertyNameSuccess = "$($filterStr)$($propertyAppend)Success"
    $pivotRow = "$($filterStr)PivotRow"

    try {
        # First grouping as row - example provider or department
        $rowGroups = $param.sourceData | Group-Object -Property $param.$pivotRow
        $provArray = @()
        
        foreach($row in $rowGroups){
            # Second grouping as column - example order type
            $colGroups = $row.Group | Group-Object -Property $param.orderTypePivotColumn

            # need to initialize all properties ahead of time, rather than dynamically adding new property 
            # initialize with 0 if summary count
            # initialize with array detail 
            $temp = fnLocal_InitializeTempPSCustomObject -Type $propertyAppend
            

            foreach($col in $colGroups) {
                $columnName = $col.Name

                # some order type is blank
                if(-not $columnName){
                    $columnName = "Other"
                }

                # just in case there is incomplete order type not listed
                if(( -not (Get-Member -InputObject $temp -Name $columnName -MemberType Properties)) ){
                    $columnName = "Other"
                }

                $temp.$columnName += $col.$pivotDataType
            }
            $provArray += $temp
            
        }
        $param.$propertyName = $provArray
        $param.$propertyNameSuccess = $true
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

}