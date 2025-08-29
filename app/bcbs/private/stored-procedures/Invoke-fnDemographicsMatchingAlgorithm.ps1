function Invoke-fnDemographicsMatchingAlgorithm {
    [CmdletBinding()]
     
    $StoredProcedure = 'dbo.spDemographicsMatchingAlgorithm'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Verbose -Message "Run demographic matching store procedure"
        $cmd.ExecuteReader()

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed to run matching algorithm: $($_.Exception.Message)"
        continue
    } finally {
        Write-Information -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}