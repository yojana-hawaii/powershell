function Initialize-fnOrderConfigs {
    [CmdletBinding()]
    param()
    Write-Information "$($MyInvocation.MyCommand.Name): Initializing the config files and create necessary PSCustomObjects"
    $order           = Get-fnOrderConfig
    
    Write-Information "$($MyInvocation.MyCommand.Name): Get order path from config file. Strip `" (double quote) > Pulling path from config file adds double quotes everywhere  "
    $orderPath          = $order.orderPath
    $sourcePath         = Join-Path -Path $orderPath -ChildPath $order.sourcePath
    $referencesPath     = Join-Path -Path $orderPath -ChildPath $order.references
    
    $deletedBucket      = (($order.delete) -replace '"',"").Split(",")
    $group              = (($order.group) -replace '"',"").Split(",")
    
    Write-Information "$($MyInvocation.MyCommand.Name): Create PSCustomObject for labs, referrals and imaging orders."
    $labHash = [PSCustomObject]@{
        type            = "Labs"
        source          = (Join-Path -Path $sourcePath -ChildPath $order.labFileName) -replace '"',""
        alarm           = (($order.labAlarm) -replace '"',"").Split(",")
        delete          = $deletedBucket
        exclude         = (($order.exclude) -replace '"',"").Split(",")
        internalList    = (Join-Path -Path $referencesPath -ChildPath $order.internalLab) -replace '"',""
        supportStaff    = (Join-Path -Path $referencesPath -ChildPath $order.labStaff) -replace '"',""
        
        summaryGroup    = $group[1]
        extSummary      = ""
        intSummary      = ""
        deletegroup     = $group[2]
        deletedata      = ""
        internalgroup   = $group[1]
        internaldata    = ""
        externalgroup   = $group[0]
        externaldata    = ""

        extDestination  = (Join-Path -Path $orderPath -ChildPath $order.externalLabDest) -replace '"',""
        intDestination  = (Join-path -Path $orderPath -ChildPath $order.internalLabDest) -replace '"',""
        delDestination  = (Join-Path -Path $orderPath -ChildPath $order.deleteDest) -replace '"',""
    }

    $consultHash = [PSCustomObject]@{
        type            = "Consult"
        source          = (Join-Path -Path $sourcePath -ChildPath $order.consultFileName) -replace '"',""
        alarm           = (($order.consultAlarm) -replace '"',"").Split(",")
        delete          = $deletedBucket
        exclude         = (($order.exclude) -replace '"',"").Split(",")
        internalList    = (Join-Path -Path $referencesPath -ChildPath $order.internalConsult) -replace '"',""
        supportStaff    = (Join-Path -Path $referencesPath -ChildPath $order.consultStaff) -replace '"',""
        
        summaryGroup    = $group[1]
        extSummary      = ""
        intSummary      = ""
        deletegroup     = $group[2]
        deletedata      = ""
        internalgroup   = $group[3]
        internaldata    = ""
        externalgroup   = $group[0]
        externaldata    = ""

        extDestination  = (Join-Path -Path $orderPath -ChildPath $order.externalConsultDest) -replace '"',""
        intDestination  = (Join-path -Path $orderPath -ChildPath $order.internalConsultDest) -replace '"',""
        delDestination  = (Join-Path -Path $orderPath -ChildPath $order.deleteDest) -replace '"',""
    }
    $imagingHash = [PSCustomObject]@{
        type            = "Imaging"
        source          = (Join-Path -Path $sourcePath  -ChildPath $order.imagingFileName) -replace '"',""
        alarm           = (($order.imagingAlarm) -replace '"',"").Split(",")
        delete          = $deletedBucket
        exclude         = (($order.exclude) -replace '"',"").Split(",")
        internalList    = (Join-Path -Path $referencesPath -ChildPath $order.internalImaging) -replace '"',""
        supportStaff    = (Join-Path -Path $referencesPath -ChildPath $order.imagingStaff) -replace '"',""
        
        summaryGroup    = $group[1]
        extSummary      = ""
        intSummary      = ""
        deletegroup     = $group[2]
        deletedata      = ""
        internalgroup   = $group[1]
        internaldata    = ""
        externalgroup   = $group[0]
        externaldata    = ""

        extDestination  = (Join-Path -Path $orderPath -ChildPath $order.externalImagingDest) -replace '"',""
        intDestination  = (Join-path -Path $orderPath -ChildPath $order.internalImagingDest) -replace '"',""
        delDestination  = (Join-Path -Path $orderPath -ChildPath $order.deleteDest) -replace '"',""
    }

    

    return @($labHash, $consultHash, $imagingHash)
}