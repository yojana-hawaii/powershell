function Initialize-fnOrderHash {

    Write-Verbose "$($MyInvocation.MyCommand.Name): Initialize config variables"

    #region - Initialization
    $orderConf = Get-fnOrderConfig

    $rootPath  = ($orderConf.rootPath) -replace '"', ""
    $rawFolder = ($orderConf.rawFolder) -replace '"', ""
    $v1Source  = ($orderConf.ordersv1file) -replace '"', ""
    $v2Source  = ($orderConf.ordersv2file) -replace '"', ""

    $provPivotRow = ($orderConf.provPivotRow) -replace '"', ""

    $references = ($orderConf.references) -replace '"', ""
    $internalLab = ($orderConf.internalLab) -replace '"', ""
    $internalConsult = ($orderConf.internalConsult) -replace '"', ""
    $internalImaging = ($orderConf.internalImaging) -replace '"', ""
    $supportStaff = ($orderConf.supportStaff) -replace '"', ""
    
    $export = ($orderConf.export) -replace '"', ""

    #endregion 
    

    return [hashtable]@{
        rawFolder = Join-Path -Path $rootPath -ChildPath $rawFolder
        # config for join
        v1Source   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $rawFolder) -ChildPath $v1Source
        v2Source   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $rawFolder) -ChildPath $v2Source

        v1Columns  = (($orderConf.v1columns) -replace '"', "") -split ","
        v2columns  = (($orderConf.v2columns) -replace '"', "") -split ","
        v1JoinColumn = ($orderConf.joinColumn) -replace '"', ""
        v2JoinColumn = ($orderConf.joinColumn) -replace '"', ""
        
        # config for exec summary
        orderTypePivotColumn = ($orderConf.pivotColumn) -replace '"', ""
        provPivotRow = $provPivotRow
        deptPivotRow = ($orderConf.deptPivotRow) -replace '"', ""
        yearPivotRow = ($orderConf.yearPivotRow) -replace '"', ""

        # config for filter by string
        delete = (($orderConf.deleteOrders) -replace '"', "") -split ","
        autoClose = (($orderConf.autoCloseOrders) -replace '"', "") -split ","
        bloodDraw = (($orderConf.bloodDraw) -replace '"', "") -split ","
        socialDeterminant = (($orderConf.socialDeterminant) -replace '"', "") -split ","
        
        # config for filter by dates
        alarm = (($orderConf.alarm) -replace '"', "") -split ","
        expired   = (($orderConf.expired) -replace '"', "") -split ","
        lastUpdate = (($orderConf.lastUpdate) -replace '"', "") -split ","
        
        # hardcoded config
        alarmDays = @{"lab"=7;"consult"=42;"imaging"=30;"procedure"=14;"default"=7}
        expiredDays = @{"lab"=180;"consult"=365;"imaging"=180;"procedure"=365;"default"=365 }
        lastUpdateDays = @{"default"=14 }
        grouByType = @{"lab"=$provPivotRow;"default"=$provPivotRow }
        
        #reference files
        internalLab       = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalLab
        internalConsult   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalConsult
        internalImaging   = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $internalImaging
        supportStaff      = Join-Path -Path (Join-Path -Path $rootPath -ChildPath $references) -ChildPath $supportStaff
         
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
        summaryFile="_summary-provider-department-year.xlsx"
        adminFile="_admin-delete-expired-plus-others.xlsx"
        unknownProvider="_unknown-approving-provider"
    }

}