function Invoke-spAdUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$user
    )

    
    $StoredProcedure = 'dbo.spAdUser'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($user.sAMAccountName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CanonicalName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sAMAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@userPrincipalName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@FirstName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DisplayName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@emailAddress", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DistinguishedName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@StreetAddress", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@HomePhone", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@MobilePhone", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OfficePhone", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Fax", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Company", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Department", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Title", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Description", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AccountExpirationDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Enabled", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastLogonDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CreatedDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ModifiedDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordNeverExpires", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordExpired", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PasswordLastSetDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ScriptPath", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LogonCount", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@EmployeeId", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Manager", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $user.CanonicalName
        $cmd.Parameters[1].Value = $user.sAMAccountName
        $cmd.Parameters[2].Value = $user.userPrincipalName
        $cmd.Parameters[3].Value = $user.FirstName
        $cmd.Parameters[4].Value = $user.LastName
        $cmd.Parameters[5].Value = $user.DisplayName
        $cmd.Parameters[6].Value = $user.EmailAddress
        $cmd.Parameters[7].Value = $user.DistinguishedName
        $cmd.Parameters[8].Value = $user.StreetAddress
        $cmd.Parameters[9].Value = $user.HomePhone
        $cmd.Parameters[10].Value = $user.MobilePhone
        $cmd.Parameters[11].Value = $user.OfficePhone
        $cmd.Parameters[12].Value = $user.Fax
        $cmd.Parameters[13].Value = $user.Company
        $cmd.Parameters[14].Value = $user.Department
        $cmd.Parameters[15].Value = $user.Title
        $cmd.Parameters[16].Value = $user.Description
        $cmd.Parameters[17].Value = $user.AccountExpirationDate
        $cmd.Parameters[18].Value = $user.Enabled
        $cmd.Parameters[19].Value = $user.LastLogonDate
        $cmd.Parameters[20].Value = $user.CreatedDate
        $cmd.Parameters[21].Value = $user.ModifiedDate
        $cmd.Parameters[22].Value = $user.PasswordNeverExpires
        $cmd.Parameters[23].Value = $user.PasswordExpired
        $cmd.Parameters[24].Value = $user.PasswordLastSetDate
        $cmd.Parameters[25].Value = $user.ScriptPath
        $cmd.Parameters[26].Value = $user.LogonCount
        $cmd.Parameters[27].Value = $user.EmployeeId
        $cmd.Parameters[28].Value = $user.Manager


       $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($user.sAMAccountName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}