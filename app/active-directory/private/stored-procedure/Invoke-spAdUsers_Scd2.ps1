function Invoke-spAdUsers_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$users
    )
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("CanonicalName", [string]) | Out-Null
    $dataTable.Columns.Add("sAMAccountName", [string]) | Out-Null
    $dataTable.Columns.Add("userPrincipalName", [string]) | Out-Null
    $dataTable.Columns.Add("FirstName", [string]) | Out-Null
    $dataTable.Columns.Add("LastName", [string]) | Out-Null
    $dataTable.Columns.Add("DisplayName", [string]) | Out-Null
    $dataTable.Columns.Add("emailAddress", [string]) | Out-Null
    $dataTable.Columns.Add("DistinguishedName", [string]) | Out-Null
    $dataTable.Columns.Add("StreetAddress", [string]) | Out-Null
    $dataTable.Columns.Add("HomePhone", [string]) | Out-Null
    $dataTable.Columns.Add("MobilePhone", [string]) | Out-Null
    $dataTable.Columns.Add("OfficePhone", [string]) | Out-Null
    $dataTable.Columns.Add("Fax", [string]) | Out-Null
    $dataTable.Columns.Add("Company", [string]) | Out-Null
    $dataTable.Columns.Add("Department", [string]) | Out-Null
    $dataTable.Columns.Add("Title", [string]) | Out-Null
    $dataTable.Columns.Add("Description", [string]) | Out-Null
    $dataTable.Columns.Add("AccountExpirationDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("Enabled", [string]) | Out-Null
    $dataTable.Columns.Add("LastLogonDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("CreatedDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("ModifiedDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("PasswordNeverExpires", [string]) | Out-Null
    $dataTable.Columns.Add("PasswordExpired", [string]) | Out-Null
    $dataTable.Columns.Add("PasswordLastSetDate", [System.DateTime]) | Out-Null
    $dataTable.Columns.Add("ScriptPath", [string]) | Out-Null
    $dataTable.Columns.Add("LogonCount", [string]) | Out-Null
    $dataTable.Columns.Add("EmployeeId", [string]) | Out-Null
    $dataTable.Columns.Add("Manager", [string]) | Out-Null

    foreach($row in $users){
        $dataTable.Rows.Add(
                $row.CanonicalName,$row.sAMAccountName,$row.userPrincipalName,$row.FirstName,$row.LastName,
                $row.DisplayName,$row.emailAddress,$row.DistinguishedName,$row.StreetAddress,$row.HomePhone,
                $row.MobilePhone,$row.OfficePhone,$row.Fax,$row.Company,$row.Department,$row.Title,
                $row.Description,$row.AccountExpirationDate,$row.Enabled,$row.LastLogonDate,
                $row.CreatedDate,$row.ModifiedDate,
                $row.PasswordNeverExpires,$row.PasswordExpired,$row.PasswordLastSetDate,
                $row.ScriptPath,$row.LogonCount,$row.EmployeeId,
                $row.Manager
            )
    }
    
    $StoredProcedure = 'dbo.spAdUsers_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@users", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpAdUsers"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import AD users to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}