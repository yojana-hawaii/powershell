function Get-fnOrganizeTickets {
    [CmdletBinding()]
    param (
        [parameter()]
        [int]$days,
        [parameter()]
        [string]$admin
    )
    
    Write-Verbose "$($MyInvocation.MyCommand.Name): Group sysaid tickets by status"

    $tickets = Invoke-spGetTicketPerAdmin -days $days -admin $admin
    $ticketByStatus = $tickets | Group-Object -Property TicketStatus | Sort-Object -Property Name -Descending      
    
    $organizedTickets = @()
    foreach($status in $ticketByStatus){
        $organizedTickets += [PSCustomObject]@{
            name = $admin
            status = $status.name
            count = $status.count
            group =  $status.Group | Select-Object TicketNumber, TicketPriority,Category,RequestUser,`
                        @{
                            label = "Subject";
                            expression = {($_.Subject).Substring(0,[Math]::Min($_.Subject.Length, 30))} # remove fluff,  only first 20 character
                        },
                        @{
                            label="date"
                            expression={Get-Date $_.RequestTime -Format "MM-dd-yyyy"}
                        },
                        @{
                            label="last-update"
                            expression={Get-Date $_.LastUpdate -Format "MM-dd-yyyy"}
                        },
                        @{
                            label = "total-updates"
                            expression = {$_.UpdateByEmail + $_.UpdateBySysaid}
                        },
                        @{
                            label = "updates-last-week"
                            expression = {$_.UpdateByEmail7Days + $_.UpdateBySysaid7Days}
                        } 
        }
    }
    return $organizedTickets
}