function Invoke-fnSpWorkstationPrinters {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$printer
    )


    $StoredProcedure = 'dbo.spWorkstationPrinters'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

    try{
        Write-Information -Message "Insert $($printer.ComputerName)"
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ComputerName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterShared", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterShareName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterDriverName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterDriverVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PrinterIP", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters[0].Value = $printer.ComputerName
        $cmd.Parameters[1].Value = $printer.PrinterName
        $cmd.Parameters[2].Value = $printer.PrinterShared
        $cmd.Parameters[3].Value = $printer.PrinterShareaName
        $cmd.Parameters[4].Value = $printer.PrinterDriverName
        $cmd.Parameters[5].Value = $printer.PrinterDriverVersion
        $cmd.Parameters[6].Value = $printer.PrinterIP

        $return = $cmd.ExecuteNonQuery()
        Write-Information "Import to sql affected $return row(s)"

    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($printer.ComputerName): $($_.Exception.Message)"
        continue
    } finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name):Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}