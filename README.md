# Powershell
learning GPO & powershell from https://github.com/EvotecIT/ 

# preparation

### install
* windows app store - powershell v7 & vs code
* vscode extension - powershell

### install modules 
* install-Module Microsoft.Graph  // api for office 365. exchange, azure ad (replaces ms-online & azure-ad)
* install-Module PnP.Powershell // sharepoint
* Install-Module ImportExcel // manipulate excel files
* Install-Module JoinModule // inner join, left join two objects 
* Install-Module SqlServer // talk to sql server

### install optional features

RSAT
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0

WSUS enabled devices to to bypass wsus firat 

# app

## active-directory

> Get object details (user, computer, & group) from active directory
>
> Get Active Directory Configurations
>
> Get Organizational Unit details

## archive-logs
> Organize log files into ..\yyyy\MM\dd folder structure
>
> Compress the folder and delete the original after x number of days

## bcbs

> Get demographic data from EMR and Payer. Upload them to SQL database. Initiate patient matching algorithm
>
> Pass it along to Human AI for validation
>
> Get gaps from payer. Get services provided from EMR or Population health application
>
> Using the matching algorithm & pop health data, fill gaps from payer.

## comp

> Get Computer details from active directory
>
> Get workstation details using WimRm or WMI, including computer specs, logged in user, local users, installed printers, installed software, available partitions, service status & connected monitors

## computer-disable

>
>
> need to figure out the logic

## computer-export

> Get details of computer status. Status to focus can change depending on needs. Upgrade to windows 11 and bitwarden encryption is focus for 2025 
> 
> Split servers, & thin client. separate machines on windows 10, windows 11 with necessary app not installed
>
> Export them into easily accesible file format & email appropriate team

## laps

> Add local user to be used for LAPS
> 
> need refactor

## mass-notification

> Get incomplete encounters. Group by providers.
> 
> need refactor

## missing-slip

> 
> 
> need refactor

## orders

> V1: 
> 
> V2: in progress


## reboot

> Get computer list to reboot. Entire list for Sunday but a smaller list of rest of the week
> 
> Reboot the computers

## sysaid

> Get tickets for the past 7 days
> 
> Send team summary email
>
> Get details of each member of the team and send their summary 

## users

> 
> 
> need to email correct people

# shared
## config-helper
## email
## SqlConnection
## utility

# shared-ignore > .gitignore
## config
## log
## organization-specific
## template
## user-input

# sql
## da-hub-inventory
## da-hub-sysaid

# Local Computer
## Computer Details
**Get-fnDomainInventory**
* set pwd
* logs
* Imports
* config and variables
* **Invoke-spGetComputersToScan** > get computers that need to be scanned. View to organize what needs to be scanned & stored proc to pull computer names to scan
* Foreach computer **Get-fnWorkstationDetails**
   * **Get-fnReadyForScan** - Test ping, winrm and wmi
      * if ping fails move on to next computer
      * **Test-fnWinRmEnabled** - check if WinRm is available
      * **Test-fnWmiEnabled** - check if Wmi is available
      * if winRm and wmi unavailable, move to next computer.
      * if wmi avaialable, try to enable winRm
      * If winRm still not available move to next computer
   * **Get-fnWorkstationSpecs** > Get workstation specds like serial, bios, manufacturer, model, ram, laptop vs desktop vs vm vs server, procesors, desk, OS, last patch, tpm etc
   * **Invoke-fnSpWorkstationSpecs**  > stored proc to save computer details to sql
   * **Get-fnWorkstationPrinter** > all printers installed in the computer
   * **Invoke-fnSpWorkstationPrinters**  > stored proc to save installed printer details to sql
   * **Get-fnWorkstationLocalUser** > all local user and associated details
   * **Invoke-fnSpWorkstationLocalUser**  > stored proc to save local users details to sql
   * if not thin client
      * **Get-fnWorkstationSoftware** > all the software installed in the computers
      * **Invoke-fnSpWorkstationSoftware**  > stored proc to save installed software details to sql
      * **Get-fnWorkstationPartition** > disk partition and size
      * **Invoke-fnSpWorkstationPartition**  > stored proc to save disk partition details to sql
      * **Get-fnWorkstationUserLoggedIn** > all the user that ever logged in and last date they logged in
      * **Invoke-fnSpWorkstationUserLoggedIn**  > stored proc to save logged in user details to sql
      * **Get-fnWorkstationServices** > get all services and status 
      * **Invoke-fnWorkstationServices**  > stored proc to save services details to sql
   * if not VM
      * **Get-fnWorkstationMonitor**
         * WimRM to get monitor count, models, resolution, serial etc 
      * **Invoke-fnWorkstationMonitor**   > stored proc to save connected monitors details to sql
## Set Local User
**Set-fnLocalUser**
* set pwd
* imports
* read config file and set variables
* **Invoke-spGetComputersWithoutUser** > call stored proc to get computers without user
* Foreach computer > check if it is online
* **fnLocal_CreateLapsUsers**
   * **Start-fnService** > Start WinRm Service if not running
   * Create a ScriptBlock to Get-LocalUser
   * Invoke-Command to run ScriptBlock get all local users
   * **fnLocal_LapsUserExists** > check if any of them is local user > verify again before attempting to create
   * if user does not exist Invoke-Command with scriptblock to create new-localUser
   * Check if the local user exists again.
   * **Stop-fnService** > Stop WinRm

# Active Directory
## Disabled Inactive Computers
## Disable Inactive Users
## Remove Users from Groups
## Get Active Diretory Details
Get-fnActiveDirectoryDetails
* set pwd
* imports
* reach config and set variables
* **Get-fnAdComputers** > get computer details including name, enabled, bitlocker, laps, OU, IP, OS etc
* **Invoke-spAdComputer** > stored proc to save computer details to sql
* **Get-fnActiveDirectory** > get AD  config including DCs, Schema Master, Dhcp Server, Default containers, etc
* **Invoke-spActiveDirectory**  > stored proc to save AD details to sql
* **Get-fnAdOrganizationalUnit** > All OU and Acl of each OU
* **Invoke-spOrganizationalUnit** > stored proc to save OU details to sql
* **Invoke-spOrganizationalUnitAcl** > stored proc to save OU Acl to sql


# Order Report

### New-fnOrderReport
* Set pwd
* Imports
* **Initialize-fnOrderConfigs** > create custom object for lab, consult & imaging with necessary details from config file
   * **Get-fnOrderConfig**> read order.conf file 
* **Initialize-fnOrderEmailConfig**> create custom object with necessary config to send email from powershell
   * **Get-fnEmailConfig** > read  email-config.conf file
   * **Set-fnEmailHtmlStart** > inital HTML tags
   * **Set-fnEmailHtmlEnd** > HTML end tags
* Loop through order objects (lab, consult, imaging)
   *  **Test-fnSourceFile** > if source file older than 7 days
      * **Update-fnInvalidSource** > no new file, update email object  
   *  **Test-fnDestinationFile** > If source file is valid, check if destination file was generated after source
      * **Update-fnValidSourceAndDestination** > no action
      * **UpdatefnInvalidDestination** > create destination files
         *  **Remove-fnOrderNotReadyForFollowup**
            * **Read-fnCsvDefaultHeader** > read cvs file
            * remove closed orders
            * remove orders not past due
            * remove any other special exclusion
         *  **Get-fnDeletedOrders**
            * separate orders to delete  
         *  **Get-fnInternalOrders**
            * separate internal orders  
         *  **Group-fnOrdersByGroupConfig**
            * Group external, internal and delete data by group properties  
         *  **Export-fnGroupedObjectToSeparateCsv**
            * Export grouped data to destination as csv file  
         *  **Set-fnEmailBodyOrderInvalidDestination**
            * Set email body
            * **Join-fnTwoOrderArray**
               *  combine two grouped arrays > align row and add new column
* Send Summary Email
   * **Set-fnEmailBodyOrder** > set email body
   * **Set-fnEmailHtmlCombine** > combine email body
   * send email
* Send Detailed Email
   *  **Send-fnOncompleteLabToSupportStaff**
      * Read all the files in destination folder
      * Read csv file with assigned support staff
      * match files in destination with support staff in csv
      * **Set-fnEmailBodySupportStaff**
         * **Set-fnEmailBodyNull** > entire body to null
         * Initialize email settings. Null to avoid accidental email with wrong confic
      * **Set-fnEmailHtmlCombine** > combine email body

### Order Object
* type          : eg. lab
* source        : \\unc
* alarm         : 7 (days)
* delete        : eg. bucket
* exclude       : eg. future, 90
* internalList  : file.csv
* supportStaff  : file.csv

* summaryGroup  : department, provider etc
* extSummary    : 
* intSummary    : 
* deleteGroup   : eg. bucket
* deletedata    : 
* internalGroup : eg. order
* internalData  :
* externalGroup : eg. provider
* externalData  :

* extDestination: \\unc
* intDestination: \\unc
* delDestination: \\unc
