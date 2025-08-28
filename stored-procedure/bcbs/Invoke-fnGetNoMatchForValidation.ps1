function Invoke-fnGetNoMatchForValidation {
    $StoredProcedure = 'dbo.spGetNoMatchForValidation'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Export no-match list for optional validation"

        $result = $cmd.ExecuteReader()
        $data = New-Object System.Data.DataTable
        $data.Load($result)
        return $data
       
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed to pull demographic data for validation: $($_.Exception.Message)"
        continue
    } finally {
        Write-Information -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}