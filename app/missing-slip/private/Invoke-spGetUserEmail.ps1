function Invoke-spGetUserEmail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$firstName,
        [Parameter(Mandatory)]
        [string]$lastName
    )

    
    $StoredProcedure = 'dbo.spGetUserEmail'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Getting email for: $firstName $lastName"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@FirstName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $firstName
        $cmd.Parameters[1].Value = $lastName

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($workstation.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}