function Export-fnDataToExcel {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param
    )
    Write-Information "$($MyInvocation.MyCommand.Name): Export to Excel"

    #try cath when there is possibility of exception
    try {

        # export data per provider
        Get-ChildItem -Path $param.export -Include * | Remove-Item
        foreach($prov in $param.provDetail){
            $fileName = "$($prov.Name) - $($prov.Total)"
            if($prov.Name -eq "") {$fileName = "_unknown Approving Provider"}
            $provPath = Join-Path -Path $param.export -ChildPath "$fileName.xlsx"
            
            if($prov.lab.count -gt 0){
                $prov.Lab | 
                    Export-Excel -Path $provPath -WorksheetName "Lab - $($prov.lab.count)" -Autosize
            }

            if($prov.Procedure.count -gt 0){
                $prov.Procedure | 
                    Export-Excel -Path $provPath -WorksheetName "Procedure - $($prov.Procedure.count)" -Autosize
            }

            
            if($prov.Imaging.count -gt 0){
                $prov.Imaging | 
                    Export-Excel -Path $provPath -WorksheetName "Imaging - $($prov.Imaging.count)" -Autosize
            }
            
            if($prov.Other.count -gt 0){
                $prov.Other | 
                    Export-Excel -Path $provPath -WorksheetName "Other - $($prov.Other.count)" -Autosize
            }
            
            if($prov.Vaccine.count -gt 0){
                $prov.Vaccine | 
                    Export-Excel -Path $provPath -WorksheetName "Vaccine - $($prov.Vaccine.count)" -Autosize
            }
            
            if($prov."Internal-Consult".count -gt 0){
                $prov."Internal-Consult" | 
                    Export-Excel -Path $provPath -WorksheetName "Internal-Consult - $($prov."Internal-Consult".count)" -Autosize
            }
            
            if($prov.Consult.count -gt 0){
                $prov.Consult | 
                    Export-Excel -Path $provPath -WorksheetName "Consult - $($prov.Consult.count)" -Autosize
            }
        }

        # export summary
        $summaryPath = Join-Path -Path $param.export -ChildPath "_summary-provider-department-year.xlsx"
        $param.provSummary | Export-Excel -Path $summaryPath -WorksheetName "Provider" -Autosize
        $param.deptSummary | Export-Excel -Path $summaryPath -WorksheetName "Department" -Autosize
        $param.yearSummary | Export-Excel -Path $summaryPath -WorksheetName "Year" -Autosize


        # export data not requiring follow up
        $queenPath = Join-Path -Path $param.export -ChildPath "_queenB.xlsx"

        $param.deleteData| 
            Select-Object PatientId, DocumentId, OrderName, OrderStatus, OrderType, Provider, Department, Bucket | 
            Export-Excel -path $queenPath -WorksheetName "Delete - $($param.deleteData.Count)" -Autosize

        $param.expiredData| 
            Select-Object PatientId, DocumentId, OrderName, OrderDate, PerformDate, LastUpdateDate, OrderStatus, OrderType, Provider, Department, Bucket |
            Export-Excel -Path $queenPath -WorksheetName "Expired - $($param.expiredData.Count)" -Autosize

        $param.socialDeterminantData| 
            Select-Object PatientId, DocumentId, OrderName, OrderStatus, OrderType, Provider, Department, Bucket | 
            Export-Excel -path $queenPath -WorksheetName "Social Determinant - $($param.socialDeterminantData.Count)" -Autosize
        
        $param.bloodDrawData| 
            Select-Object PatientId, DocumentId, OrderName, OrderStatus, OrderType, Provider, Department, Bucket | 
            Export-Excel -path $queenPath -WorksheetName "Blood Draw - $($param.bloodDrawData.Count)" -Autosize
        
        
        $param.alarmData| 
            Select-Object PatientId, DocumentId, OrderName, OrderDate, PerformDate, LastUpdateDate, OrderStatus, OrderType, Provider, Department, Bucket | 
            Export-Excel -Path $queenPath -WorksheetName "Ignore - Alarm - $($param.alarmData.Count)" -Autosize
        
        $param.lastUpdateData| 
            Select-Object PatientId, DocumentId, OrderName , OrderDate, PerformDate, LastUpdateDate,  OrderStatus, OrderType, Provider, Department, Bucket | 
            Export-Excel -Path $queenPath -WorksheetName "Ignore - Updated 2 weeks - $($param.lastUpdateData.Count)" -Autosize
        
        $param.exportSuccess = $true
        
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
    return $return
}