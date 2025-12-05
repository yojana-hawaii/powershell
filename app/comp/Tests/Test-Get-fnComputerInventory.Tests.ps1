Describe "Get-fnComputerInventory" {

    BeforeAll {
        # Mock required functions and commands
        Mock Get-fnConfig { @{{ vpn_ip_suffix = 'mock-vpn-ip' }} }
        Mock Get-fnAdComputers { @( @{ sAMAccountName = 'test-computer-1' }, @{ sAMAccountName = 'test-computer-2' } ) }
        Mock Invoke-spAdComputer {}
        Mock Invoke-spGetComputersToScan { @( @{ ComputerName = 'comp1' }, @{ ComputerName = 'comp2' } ) }
        Mock Get-fnWorkstationDetails {}
    }

    It "Should call Get-fnConfig and retrieve configuration details" {
        Get-fnComputerInventory -Verbose
        Assert-MockCalled Get-fnConfig -Exactly 1 -Scope It
    }

    It "Should process new computers and call Invoke-spAdComputer" {
        Get-fnComputerInventory -Verbose
        Assert-MockCalled Invoke-spAdComputer -Times 2 -Scope It
    }

    It "Should scan computers and call Get-fnWorkstationDetails" {
        Get-fnComputerInventory -Verbose
        Assert-MockCalled Get-fnWorkstationDetails -Times 2 -Scope It
    }
}