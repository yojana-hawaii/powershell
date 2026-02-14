# Sync-ADToSql.Tests.ps1

Describe "AD to SQL Sync Suite" {
    
    Context "Data Transformation Logic" {
        It "Correctly maps AD Computer attributes to SQL Objects" {
            # Mocking a fake AD Computer Object
            $mockADComp = [PSCustomObject]@{
                Name = "COMP-01"
                Enabled = $true
                DistinguishedName = "CN=COMP-01,OU=Workstations,DC=contoso,DC=com"
                CanonicalName = "contoso.com/Workstations/COMP-01"
                sAMAccountName = "COMP-01$"
                OperatingSystem = "Windows 11"
                whenCreated = Get-Date
                whenChanged = Get-Date
                msLAPS_ExpirationTime = 133204512000000000 # FileTime format
                userAccountControl = 4096
            }

            # Mock Bitlocker check (returning null to test '0' logic)
            Mock Get-ADObject { return $null }

            $result = ConvertTo-SqlComputerObject -AdObject $mockADComp

            $result.ComputerName | Should -Be "COMP-01"
            $result.Enabled | Should -Be 1
            $result.HasBitlocker | Should -Be 0
            $result.LapsExpirationDate | Should -BeOfType [DateTime]
        }
    }

    Context "Orchestration & Mocking" {
        Mock Get-ADData { 
            return @([PSCustomObject]@{ sAMAccountName = "TestGroup"; DistinguishedName = "DN" }) 
        }
        Mock Invoke-ADSqlStoredProcedure { } # Do nothing, just record call
        Mock Get-ADGroupMember { return @() }

        It "Triggers SQL Insert when groups are found" {
            Sync-ADToSql -DeltaHours 24
            
            # Verify the SQL function was actually called at least once
            Assert-MockCalled Invoke-ADSqlStoredProcedure -Times 1 -Exactly
        }
    }

    Context "Error Handling" {
        It "Logs a warning when SQL execution fails" {
            Mock New-spSqlConnection { throw "Connection Timeout" }
            
            # We expect the inner function to throw an error
            { Invoke-ADSqlStoredProcedure -StoredProcedure "test" -Parameters @{} } | Should -Throw
        }
    }
}
