function Join-fnTwoSourceFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]$param
    )
    Write-Verbose "$($MyInvocation.MyCommand.Name): Join the two csv files"


    $v1Valid = Test-fnSourceFile -sourceFile $param.v1Source -sourceFileValidDays 7
    $v2Valid = Test-fnSourceFile -sourceFile $param.v2Source -sourceFileValidDays 7
    if(-not ($v1Valid -and $v2Valid)){
        return
    }
    $param.sourceFileValid = $true
    
    #try cath when there is possibility of exception
    try { 
        $v1 = Import-csv -Path $param.v1Source -Delimiter "," |  Select-Object $param.v1columns
        $v2 = Import-csv -Path $param.v2Source -Delimiter "," |  Select-Object $param.v2columns
        write-host "joining"
        $param.sourceData = $v2 | LeftJoin $v1 -On $param.v2JoinColumn -Equals $param.v1JoinColumn 
        
        write-host "add year column, Perform date can be blank. Use Order date in that case"
        $param.sourceData | ForEach-Object {
            $conditionalDate = if($_.performDate){Get-Date $_.performDate} else {Get-Date $_.OrderDate }
            $_ | Add-Member -MemberType "NoteProperty" -Name "Year" -Value $conditionalDate.Year.ToString()
            if($_.Provider -eq "" -or $null -eq $_.Provider) {
                $_.Provider = "unknown"
            }
        }

        $param.joinSuccess = $true
        $param.totalOrders = ($param.sourceData).count
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }
}