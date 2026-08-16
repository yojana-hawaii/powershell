function Invoke-fnSpWorkstationLocalUser_Scd2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$localUsers
    )

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ComputerName", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserName", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserStatus", [string]) | Out-Null

    $dataTable.Columns.Add("LocalUserLocalAccount", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserPasswordExpires", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserDisabled", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserLockout", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserPasswordChangeable", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserPasswordRequired", [string]) | Out-Null

    $dataTable.Columns.Add("LocalUserDescription", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserFullName", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserAccountType", [string]) | Out-Null
    $dataTable.Columns.Add("LocalUserInstallDate", [string]) | Out-Null

    foreach($row in $localUsers){
        $dataTable.Rows.Add(
                $row.ComputerName, $row.Name, $row.Status, 
                $row.LocalAccount, $row.PasswordExpires, $row.Disabled, $row.Lockout, $row.PasswordChangeable, $row.PasswordRequired,
                $row.Description, $row.Fullname, $row.AccountType, $row.InstallDate
            )
    }
    
    $StoredProcedure = 'dbo.spWorkstationLocalUsers_Scd2'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    $param = $cmd.Parameters.Add("@localusers", [System.Data.SqlDbType]::Structured)
    $param.TypeName = "dbo.tvpWorkstationLocalUsers"
    $param.Value = $dataTable

    try{
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Verbose "Import local users to sql. Try branch success."
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}

