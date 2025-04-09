# Local Computer

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

  
# Powershell
learning GPO & powershell from https://github.com/EotecIT/ 

to do
* AD computer
   * LAPS
   * bitlocker
* password policy
* gpo
* computer details
   * <del> Monitors
   * <del> Printers
   * <del> Users Logged In
   * <del> Local Users
   * <del> Services
   * <del> Software
   * <del> Model, Ram, Disk, Tpm, Processor, Bios, OS, Last Patch
   * <del> laptop vs desktop vs VM vs server vs thin client vs vpn
  
 * Get-Process of cmputer
* OU
* groups
* domain admin, enterprise admin
* adfs



App 
login
* display indivdual user details
* get all direct reports given manager
* deactivate users without activity in 2 weeks
* add users to group depending on job title
* logon script by job title
* OU by job title
* which user has logged into which computer. last 365 days??


Datawarehouse
user
* get all users and approprite details
* get changes in the user to update warehouse

group
* get all groups
* get all users in a group

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
         * **Set-fnEmailBodyNull > entire body to null
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
