function Invoke-ADSqlStoredProcedure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string]$StoredProcedure,
        [Parameter(Mandatory)] [hashtable]$Parameters
    )
    process {
        $conn = $null
        try {
            # Use your existing New-spSqlConnection logic
            $connectionDetails = New-spSqlConnection -StoredProcedureName $StoredProcedure
            $conn = $connectionDetails[0]
            $cmd  = $connectionDetails[1]

            foreach ($key in $Parameters.Keys) {
                $paramName = if ($key -match "^@") { $key } else { "@$key" }
                $cmd.Parameters.AddWithValue($paramName, ($Parameters[$key] ?? [DBNull]::Value)) | Out-Null
            }

            $rows = $cmd.ExecuteNonQuery()
            Write-Debug "SP $StoredProcedure executed. Rows affected: $rows"
        }
        catch {
            Write-Warning "SQL Error in $StoredProcedure : $($_.Exception.Message)"
            throw $_ 
        }
        finally {
            if ($null -ne $conn) { Close-spSqlConnection -cmd $cmd -conn $conn }
        }
    }
}
