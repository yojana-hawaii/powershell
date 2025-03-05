function Invoke-spOrganizationalUnit {
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Object]$organizational_unit
    )


    $StoredProcedure = 'dbo.spOrganizationalUnit'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    try{
        Write-Verbose -Message "Insert OU $($ou.CanonicalName)"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CanonicalName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Description", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ou_created", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ou_modified", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ou_deleted", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DistinguishedName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ManagedBy", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ObjectGuid", [System.Data.SqlDbType]::Guid)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Owner", [System.Data.SqlDbType]::VarChar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Group", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ExtendedAclCount", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ProtectiodFromAccidentalDeletion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AreAccessRulesProtected", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AreAuditRulesProtected", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AreAccessRulesCanonical", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AreAuditRulesCanonical", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $ou.CanonicalName
        $cmd.Parameters[1].Value = $ou.Description
        $cmd.Parameters[2].Value = $ou.Created
        $cmd.Parameters[3].Value = $ou.Modified
        $cmd.Parameters[4].Value = $ou.Deleted
        $cmd.Parameters[5].Value = $ou.DistinguishedName
        $cmd.Parameters[6].Value = $ou.ManagedBy
        $cmd.Parameters[7].Value = $ou.ObjectGuid
        $cmd.Parameters[8].Value = $ou.Owner
        $cmd.Parameters[9].Value = $ou.Group
        $cmd.Parameters[10].Value = $ou.ExtendedAclCount
        $cmd.Parameters[11].Value = $ou.ProtectedFromAccidentalDeletion
        $cmd.Parameters[12].Value = $ou.AreAccessRulesProtected
        $cmd.Parameters[13].Value = $ou.AreAuditRulesProtected
        $cmd.Parameters[14].Value = $ou.AreAccessRulesCanonical
        $cmd.Parameters[15].Value = $ou.AreAuditRulesCanonical
        
        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}