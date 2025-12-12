function Invoke-spGetHpScannerComputer {
    [CmdletBinding()]
    param ()
    $StoredProcedure = 'dbo.spGetComputersWithHpScanner'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Get computers with HP scanner driver 
            1. vendor HP
            2. always include software name - HP Scan Basic Device Software
            3. anything with s3 and s4 but excludes 5000 in software
            3a. however it seems s3 is 3000 and s4 is 5000. it might be redundant logic"
        

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