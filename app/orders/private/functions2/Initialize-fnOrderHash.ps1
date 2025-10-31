function Initialize-fnOrderHash {

    Write-Verbose "$($MyInvocation.MyCommand.Name): Initialize config variables"

    #region - Initialization
    $orderConf = Get-fnOrderConfig
    $rootPath  = ($orderConf.rootPath) -replace '"', ""
    $rawFolder = ($orderConf.rawFolder) -replace '"', ""

    $v1Source  = ($orderConf.ordersv1file) -replace '"', ""
    $v1columns = ($orderConf.v1columns) -replace '"', ""
    $v2Source  = ($orderConf.ordersv2file) -replace '"', ""
    $v2columns = ($orderConf.v2columns) -replace '"', ""
    $joinColumn = ($orderConf.joinColumn) -replace '"', ""

    $provPivotRow = ($orderConf.provPivotRow) -replace '"', ""
    $deptPivotRow = ($orderConf.deptPivotRow) -replace '"', ""
    $yearPivotRow = ($orderConf.yearPivotRow) -replace '"', ""
    $orderTypePivotColumn = ($orderConf.pivotColumn) -replace '"', ""

    $deleteOrders = ($orderConf.deleteOrders) -replace '"', ""
    $autoClose = ($orderConf.autoCloseOrders) -replace '"', ""
    $bloodDraw = ($orderConf.bloodDraw) -replace '"', ""
    $socialDeterminant = ($orderConf.socialDeterminant) -replace '"', ""
    
    $alarm = ($orderConf.alarm) -replace '"', ""
    $lastUpdate = ($orderConf.lastUpdate) -replace '"', ""
    $expired = ($orderConf.expired) -replace '"', ""

    $references = ($orderConf.references) -replace '"', ""
    $internalLab = ($orderConf.internalLab) -replace '"', ""
    $internalConsult = ($orderConf.internalConsult) -replace '"', ""
    $internalImaging = ($orderConf.internalImaging) -replace '"', ""
    
    $export = ($orderConf.export) -replace '"', ""

    #endregion 
    

    return [hashtable]@{
        # config for join
        v1Source   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $rawFolder) -ChildPath $v1Source
        v2Source   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $rawFolder) -ChildPath $v2Source
        v1Columns  = $v1columns -split ","
        v2columns  = $v2columns -split ","
        v1JoinColumn = $joinColumn
        v2JoinColumn = $joinColumn
        
        # config for exec summary
        orderTypePivotColumn = $orderTypePivotColumn
        provPivotRow = $provPivotRow
        deptPivotRow = $deptPivotRow
        yearPivotRow = $yearPivotRow

        # config for filter by string
        delete = $deleteOrders -split ","
        autoClose = $autoClose -split ","
        bloodDraw = $bloodDraw -split ","
        socialDeterminant = $socialDeterminant -split ","
        
        # config for filter by dates
        alarm = $alarm -split ","
        expired   = $expired -split ","
        lastUpdate = $lastUpdate -split ","
        
        # hardcoded config
        alarmDays = @{"lab"=7;"consult"=42;"imaging"=30;"procedure"=14;"default"=7}
        expiredDays = @{"lab"=180;"consult"=365;"imaging"=180;"procedure"=365;"default"=365 }
        lastUpdateDays = @{"default"=14 }
        grouByType = @{"lab"=$provPivotRow;"default"=$provPivotRow }
        
        #reference files
        internalLab       = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalLab
        internalConsult   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalConsult
        internalImaging   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalImaging

        # calculated
        sourceData=""
        
        deleteData=""
        autoCloseData=""
        bloodDrawData=""
        socialDeterminantData=""
        
        alarmData=""
        expiredData=""
        lastUpdateData=""
        
        provSummary=""
        deptSummary=""
        yearSummary=""
        provDetail=""

        # bool
        sourceFileValid = $false
        joinSuccess = $false
        splitSuccess=$false

        provSummarySuccess = $false
        deptSummarySuccess = $false
        yearSummarySuccess = $false
        provDetailSuccess = $false
        exportSuccess = $false
        # count
        totalOrders=0
        export=Join-Path -Path $rootPath -ChildPath $export
    }

}