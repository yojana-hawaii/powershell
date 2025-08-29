function Invoke-fnImportEmrDemographics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$demographics
    )

    
    $StoredProcedure = 'dbo.spImportEmrDemographics'
    $connection = New-spSqlConnection -StoredProcedureName $StoredProcedure
    $conn = $connection[0]
    $cmd = $connection[1]

     try{
        Write-Information -Message "Insert $($demographics.'patient-id')"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientname", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientfirst", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientlast", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientdob", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientsex", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientaddress1", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientaddress2", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientcity", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientzip", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientlastseen", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientnextappt", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@patientguarantor", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@primaryinsurancename", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@primaryinsuranceid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@primarypolicyholderid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@primarypolicyholdername", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@secondaryinsurancename", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@secondaryinsuranceid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@secondarypolicyholderid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@secondarypolicyholdername", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@tertiaryinsurancename", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@tertiaryinsuranceid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@tertiarypolicyholderid", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@tertiarypolicyholdername", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null



        $cmd.Parameters[0].Value = $demographics.'patient-id'
        $cmd.Parameters[1].Value = $demographics.'patient-name'
        $cmd.Parameters[2].Value = $demographics.'patient-first'
        $cmd.Parameters[3].Value = $demographics.'patient-last'
        $cmd.Parameters[4].Value = $demographics.'patient-dob'
        $cmd.Parameters[5].Value = $demographics.'patient-sex'
        $cmd.Parameters[6].Value = $demographics.'patient-address1'
        $cmd.Parameters[7].Value = $demographics.'patient-address2'
        $cmd.Parameters[8].Value = $demographics.'patient-city'
        $cmd.Parameters[9].Value = $demographics.'patient-zip'
        $cmd.Parameters[10].Value = $demographics.'patient-last-seen'
        $cmd.Parameters[11].Value = $demographics.'patient-next-appt'
        $cmd.Parameters[12].Value = $demographics.'patient-guarantor'
        $cmd.Parameters[13].Value = $demographics.'primary-insurance-name'
        $cmd.Parameters[14].Value = $demographics.'primary-insurance-id'
        $cmd.Parameters[15].Value = $demographics.'primary-policy-holder-id'
        $cmd.Parameters[16].Value = $demographics.'primary-policy-holder-name'
        $cmd.Parameters[17].Value = $demographics.'secondary-insurance-name'
        $cmd.Parameters[18].Value = $demographics.'secondary-insurance-id'
        $cmd.Parameters[19].Value = $demographics.'secondary-policy-holder-id'
        $cmd.Parameters[20].Value = $demographics.'secondary-policy-holder-name'
        $cmd.Parameters[21].Value = $demographics.'tertiary-insurance-name'
        $cmd.Parameters[22].Value = $demographics.'tertiary-insurance-id'
        $cmd.Parameters[23].Value = $demographics.'tertiary-policy-holder-id'
        $cmd.Parameters[24].Value = $demographics.'tertiary-policy-holder-name'

        $return = $cmd.ExecuteNonQuery()
        Write-Information "EMR import to sql affected $return row(s)"
    } catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($demographics.'patient-id'): $($_.Exception.Message)"
        continue
    } finally {
        Write-Information -Message "Closing Sql Connection"
        Close-spSqlConnection -cmd $cmd -conn $conn
    }
}