function Invoke-spAdGroupMembers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$groupMember
    )

    
    $StoredProcedure = 'dbo.spAdGroupMembers'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Insert $($groupMember.GroupSamAccountName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@GroupSamAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Username", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ObjectClass", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $groupMember.GroupSamAccountName
        $cmd.Parameters[1].Value = $groupMember.Username
        $cmd.Parameters[2].Value = $groupMember.ObjectClass

        $return = $cmd.ExecuteNonQuery()
        if($return -eq 1){
            Write-Verbose "$($MyInvocation.MyCommand.Name): Sql insert success."
        } else {
            Write-Warning "$($MyInvocation.MyCommand.Name): Sql insert failed: $($_.Exception.Message) "
        }

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($groupMember.GroupsAMAccountName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}