function Invoke-fnSpGetComputerTaskList {
    [CmdletBinding()]
    param ()

    $StoredProcedure = 'dbo.spGetComputerTaskList'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get all computer"

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed : $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}