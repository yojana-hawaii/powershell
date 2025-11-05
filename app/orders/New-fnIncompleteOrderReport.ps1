set-location "\\fileserver\it\apps\powershell"

function New-fnIncompleteOrderReport {
    #region - Import necessary configs and private functions #>

    Write-Verbose "$($MyInvocation.MyCommand.Name): Import necessary private functions & config & utility"
    $private    = @(Get-ChildItem -Path "$PWD\app\orders\private\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $utility    = @(Get-ChildItem -Path "$PWD\shared\utility\*.ps1"    -ErrorAction SilentlyContinue -Recurse)
    $sqlConn    = @(Get-ChildItem -Path "$PWD\shared\SqlConnection\*.ps1"      -ErrorAction SilentlyContinue -Recurse)
    $config     = @(Get-ChildItem -Path "$PWD\shared\config-helper\Get-fnConfig.ps1"    -ErrorAction SilentlyContinue )
    $emailConf  = @(Get-ChildItem -Path "$PWD\shared\email\*.ps1" -ErrorAction SilentlyContinue -Recurse)
    
    foreach ($import in @($utility + $private + $sqlConn + $config + $emailConf)){
        try{
            . $import.Fullname
            Write-Information "$($MyInvocation.MyCommand.Name): Importing $($import.Fullname)"
        } catch {
            Write-Error -Message "$($MyInvocation.MyCommand.Name): Failed to import functions from $($import.Fullname): $_"
            $true
        }  
    }
    
    Import-Module JoinModule
    Import-Module ImportExcel
    Remove-Variable import, utility, private, sqlConn, config, emailConf
    #endregion
    
    $startTimer = Start-Timer
    $orderHash  = Initialize-fnOrderHash 
    $email = Initialize-fnEmailConfig
    
    Write-Information "JOIN TWO CSV FILES"
    Join-fnTwoSourceFile -param $orderHash

    # if the order data is older than 7 days
    if(-not $orderHash.sourceFileValid){
        # do something > maybe email syaing download latest files  
        Get-fnEmailConfig_MissingLatestData -email $email
        Send-fnEmail -email $email
        return
    }
    
    Write-Information "ORGANIZE DATA - INTERNAL ORDERS, DELETED. EXPIRED, UPDATED IN 14 DAYS, NO ALARM YET, SDOH, BLOOD DRAW, NEED FOLLOW UP"
    if( $orderHash.joinSuccess){
        Set-fnInternalOrders -param $orderHash -filterStr "consult"
        # Set-fnInternalOrders -param $orderHash -filterStr "lab" # combine all lab in one
        Set-fnInternalOrders -param $orderHash -filterStr "imaging"
        Split-fnIncompleteOrders -param $orderHash
    }
    
    Write-Information "GROUP DATA - BY PROV FOR FOLLOW UP AND SUMMARY FOR MANAGEMENT"
    if($orderHash.splitSuccess){
        # details per prov
        Get-fnGroupedSummary -param $orderHash -filterStr "prov" -pivotDataType "Group"
        # exec summary
        Get-fnGroupedSummary -param $orderHash -filterStr "prov" -pivotDataType "Count"
        Get-fnGroupedSummary -param $orderHash -filterStr "dept" -pivotDataType "Count"
        Get-fnGroupedSummary -param $orderHash -filterStr "year" -pivotDataType "Count"
    }

    Write-Information "EXPORT TO EXCEL"
    if($orderHash.provSummarySuccess -and $orderHash.deptSummarySuccess -and $orderHash.provDetailSuccess -and $orderHash.yearSummarySuccess){
        Export-fnDataToExcel -param $orderHash
    }

    Write-Information "ORGANIZE & SEND EMAIL"
    if($orderHash.exportSuccess){

        # email summary 
        Get-fnEmailConfig_IncompleteOrdersSummary -email $email -orderHash $orderHash
        Send-fnEmail -email $email
        
        
        # email individual staff
        $supportStaffList = Read-fnCsvDefaultHeader -filename $orderHash.supportStaff
        
        foreach($prov in $orderHash.provDetail){
            $email.From = $email.supportStaffFrom
            $email.cc = $email.supportStaffCC 

            $email.To = Get-fnSupportStaffEmail -provider $prov.Name -supportStaffList $supportStaffList

            Get-fnEmailConfig_IncompleteOrdersDetails -email $email -providerDetail $prov
            Send-fnEmail -email $email
        }
        
    }

    $totalTime = Stop-Timer -Start $startTimer
    Write-Verbose "$($MyInvocation.MyCommand.Name): Import demographics complete. It took $totalTime"    
}
$filenameAppend = Get-Date -Format "yyyMMddHHmm"

Start-Transcript -Path "$pwd\shared-ignore\log\$($MyInvocation.MyCommand.Name)_$filenameAppend.txt" -Append
$verbosePreference = "continue"
New-fnIncompleteOrderReport -Verbose -InformationAction continue
Stop-Transcript