function Get-fnInactiveUsers {

    Write-Information "$($MyInvocation.MyCommand.Name):  GET ALL INACTIVE USERS FROM SELECT OU."
    $ouConf = Get-fnOuConfig 
    $employee_ou = ($ouConf.employee_ou) -replace '"', ""
    $student_ou = ($ouConf.student_ou) -replace '"', ""
    $vendor_ou = ($ouConf.vendor_ou) -replace '"', ""

    $inactiveUsers = @()    
    $inactiveUsers += Get-fnInactiveUsersByOU -ou $vendor_ou -type "Vendor"
    $inactiveUsers += Get-fnInactiveUsersByOU -ou $employee_ou -type "Staff"
    $inactiveUsers += Get-fnInactiveUsersByOU -ou $student_ou -type "Student"

    return $inactiveUsers
}