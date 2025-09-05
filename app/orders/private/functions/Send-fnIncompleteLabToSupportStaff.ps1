function Send-fnIncompleteLabToSupportStaff {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$orderPath,
        [parameter()]
        [string]$supportStaffPath,
        [parameter()]
        [system.object]$email
    )

    Write-Information "$($MyInvocation.MyCommand.Name): Get incomplete lab file names and notify associated support staff"

    $files = Get-ChildItem -Path $orderPath
    $supportStaff = Read-fnCsvDefaultHeader -filename $supportStaffPath
    $orderAssignment = @()

    foreach($file in $files){
        $orderDetail = ($file.name -split "_")

        $orderProviderFirst = $orderDetail[1]
        $orderProviderLast = $orderDetail[0]
        $incompleteOrderCount = $orderDetail[-2]
        $matchFound = $false

       

        foreach($staff in $supportStaff){
            # some people have space in first or last name
            $assignProviderFirst = ($staff.provider_first).Replace(" ","-")
            $assignPRoviderLast =  ($staff.provider_last).Replace(" ","-")

            if($orderProviderFirst -eq $assignProviderFirst -and $orderProviderLast -eq $assignPRoviderLast ){
                #some support staff have more than one provider
                $orderAssignment += [PSCustomObject]@{
                    Staff = $staff.Staff_first
                    Email = $staff.Staff_email
                    Provider = "$orderProviderFirst $orderProviderLast"
                    File = "$orderPath\$file"
                    Count = $incompleteOrderCount
                }  
                $matchFound = $true
                break
            }
        }
        if(-not $matchFound){
            $orderAssignment += [PSCustomObject]@{
                Staff = "Unknown"
                Email = $email.supportFrom
                Provider = "$orderProviderFirst $orderProviderLast"
                File = "$orderPath\$file"
                Count = $incompleteOrderCount
            } 
        }
    }
    #new loop because one staff can have more than one assigned provider. 
    $orderAssignment | Group-Object -Property Email | ForEach-Object {
        Set-fnEmailBodySupportStaff -email $email -task $_
        Set-fnEmailHtmlCombine -email $email
        Send-MailMessage -From $email.from -To $email.to -Cc $email.cc -Subject $email.subject -Body $email.body -SmtpServer $email.smtp -BodyAsHtml

    }
}
