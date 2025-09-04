function Invoke-spOrganizationalUnitAcl{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Object]$acl,
        [Parameter()]
        [guid]$guid
    )
    $StoredProcedure = 'dbo.spOrganizationalUnitAcl'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    try{
        Write-Verbose -Message "Insert ACL $($acl.IdentityReference)"
        
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsInherited", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IdentityReference", [System.Data.SqlDbType]::NTAccount)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@InheritanceType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@AccessControlType", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@InheritedObjectType", [System.Data.SqlDbType]::Guid)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ActiveDirectoryRights", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ObjectType", [System.Data.SqlDbType]::Guid)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PropagationFlags", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@InheritanceFlags", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ObjectFlags", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ObjectGuid", [System.Data.SqlDbType]::Guid)))|Out-Null
        
        $cmd.Parameters[0].Value = $acl.IsInherited
        $cmd.Parameters[1].Value = ($acl.IdentityReference).ToString()
        $cmd.Parameters[2].Value = $acl.InheritanceType
        $cmd.Parameters[3].Value = $acl.AccessControlType
        $cmd.Parameters[4].Value = $acl.InheritedObjectType
        $cmd.Parameters[5].Value = $acl.ActiveDirectoryRights
        $cmd.Parameters[6].Value = $acl.ObjectType
        $cmd.Parameters[7].Value = $acl.PropagationFlags
        $cmd.Parameters[8].Value = $acl.InheritanceFlags
        $cmd.Parameters[9].Value = $acl.ObjectFlags
        $cmd.Parameters[10].Value = $guid
        
        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"}

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed: $($_.Exception.Message) "
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }

}
