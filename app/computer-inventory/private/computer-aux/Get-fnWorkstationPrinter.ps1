

function Get-fnWorkstationPrinter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$computerName
    )
    Write-Information "$($MyInvocation.MyCommand.Name) geting printer from: $($computerName)"
    try {
        $drivers = Invoke-Command -ComputerName $computerName `
                    -ScriptBlock { 
                        Get-PrinterDriver -name * | Select-Object Name, Provider,IsPackageAware, `
                            @{Name="DriverVersion"; Expression={
                                $ver = $_.DriverVersion
                                $rev = $ver -band 0xffff
                                $build = ($ver -shr 16) -band 0xffff
                                $minor = ($ver -shr 32) -band 0xffff
                                $major = ($ver -shr 48) -band 0xffff
                                "$major.$minor.$build.$rev"
                            };}
                    }

        
        Get-CimInstance -Class win32_Printer -ComputerName $computerName| ForEach-Object {
            $ThisPrintDriverName = $_.DriverName
            $ThisDriver = $drivers | Where-Object {  $_.Name -eq $ThisPrintDriverName }

            $localPrinter = [PSCustomObject]@{
                    ComputerName = $computerName
                    PrinterName = $_.Name
                    PrinterShared = $_.Shared
                    PrinterShareName = $_.ShareName
                    PrinterDriverName = $_.DriverName
                    PrinterDriverVersion = $ThisDriver.DriverVersion
                    PrinterIP = $_.PortName
                }
            return $localPrinter
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed for $($computerName): $($_.Exception.Message)"
    }
}