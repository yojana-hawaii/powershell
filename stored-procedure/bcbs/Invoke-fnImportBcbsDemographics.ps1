function Invoke-fnImportBcbsDemographics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$demographics
    )

    
    $StoredProcedure = 'dbo.spImportBcbsDemographics'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($demographics.'HMSA MbrUID')"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaMemberId", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaDoB", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaSubscriberId", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaGender", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaAddr1", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaAddr2", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaCity", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaState", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaZip", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HmsaPhone", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null


        $cmd.Parameters[0].Value = $demographics.'HMSA MbrUID'
        $cmd.Parameters[1].Value = $demographics.'Unique Member Name'
        $cmd.Parameters[2].Value = $demographics.'DOB'
        $cmd.Parameters[3].Value = $demographics.'Subscriber Number'
        $cmd.Parameters[4].Value = $demographics.'Gender'
        $cmd.Parameters[5].Value = $demographics.'Mail_addr1'
        $cmd.Parameters[6].Value = if($null -eq $demographics.'Mail_addr2') {""} else {$demographics.'Mail_addr2'}
        $cmd.Parameters[7].Value = $demographics.'Mail_city'
        $cmd.Parameters[8].Value = $demographics.'Mail_state'
        $cmd.Parameters[9].Value = $demographics.'Mail_zip'
        $cmd.Parameters[10].Value = if($null -eq $demographics.'Mail_phone') {""} else {$demographics.'Mail_phone'}

        $return = $cmd.ExecuteNonQuery()
        Write-Information "BCBS import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($demographics.'HMSA MbrUID'): $($_.Exception.Message)"
        continue
    } finally {
        Write-Information -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}

