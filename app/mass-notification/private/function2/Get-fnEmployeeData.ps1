function Get-fnEmployeeData {
    $sourceValid = Test-fnSourceFile -sourceFile $sourcefile -sourceFileValidDays 7
    if(-not $sourceValid){
        # email HR. need new file
        return
    }

    try {

        $data = Import-Excel -Path $sourcefile

        $data | ForEach-Object {

            $emp = Get-fnEmployeeDetailsFromAD -lastCommaFirstName $_.'Employee Name'
            $_ | Add-Member -MemberType "NoteProperty" -Name "First Name" -Value $emp.GivenName
            $_ | Add-Member -MemberType "NoteProperty" -Name "Last Name" -Value $emp.Surname
            $_ | Add-Member -MemberType "NoteProperty" -Name "E-mail Address" -Value $emp.mail
            $_ | Add-Member -MemberType "NoteProperty" -Name "Phone" -Value $_.'Cell Phone'
            $_ | Add-Member -MemberType "NoteProperty" -Name "StaffEmail" -Value $emp.mail


            if($null -eq $_.'Manager Name'){
                $_ | Add-Member -MemberType "NoteProperty" -Name "Group Assignments" -Value "no manager"
                return
            }
            $mngr = Get-fnEmployeeDetailsFromAD -lastCommaFirstName $_.'Manager Name'
            
            $_ | Add-Member -MemberType "NoteProperty" -Name "Group Assignments" -Value "$($mngr.GivenName) $($mngr.Surname)"
            $_ | Add-Member -MemberType "NoteProperty" -Name "ManagerFirst" -Value $mngr.GivenName
            $_ | Add-Member -MemberType "NoteProperty" -Name "ManagerLast" -Value $mngr.Surname
            $_ | Add-Member -MemberType "NoteProperty" -Name "ManagerEmail" -Value $mngr.mail

            

            
        }
    }
    catch {
        Write-Warning "$($MyInvocation.MyCommand.Name) failed $(): $($_.Exception.Message)"
    }

    return $data
}