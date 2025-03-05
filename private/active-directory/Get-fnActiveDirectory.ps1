function Get-fnActiveDirectory {
    [CmdletBinding()]
    param()

    $forest  = Get-fnForest
    $domain  = Get-fnDomain
    $rootDse = Get-fnRootDse

    $data = [ordered]@{}
    $data.Forest                        = $domain.Forest
    $data.Domain                        = $domain.DNSRoot
    $data.NetBiosName                   = $domain.NetBiosName
    $data.DomainFunctionality           = $rootDse.DomainFunctionality 
    $data.DomainControllerFunctionality = $rootDse.domainControllerFunctionality
    $data.DistinguishedName             = $domain.DistinguishedName

    $data.DomainController              = (Get-fnDomainController) -join ","
    $data.GlobalCatalog                 = (Get-fnGlobalCatalog) -join ","
    $data.InfrastructureMaster          = $domain.InfrastructureMaster
    $data.SchemaMaster                  = $forest.SchemaMaster
    $data.DomainNamingMaster            = $forest.DomainNamingMaster
    $data.PDCEmulator                   = $domain.PDCEmulator
    $data.RIDMaster                     = $domain.RIDMaster
    $data.ReplicaDirectoryServers       = ($domain.ReplicaDirectoryServers) -join ","
    $data.ReadOnlyDC                    = Get-fnRodc 
    $data.DomainControllerReplication   = Get-fnDomainControllerReplication -Server (Get-fnDomainController).DomainController
    $data.rIDAvailablePool              = Get-fnDomainRids -DistinguishedName $domain.DistinguishedName -RidMaster $domain.RIDMaster
    
    $data.DhcpServer                    = (Get-fnDhcpServer) -join ","
    $data.DhcpServerOther               = "+ firewall + more???"

    $data.ComputersContainer                    = $domain.ComputersContainer
    $data.DeletedObjectsContainer               = $domain.DeletedObjectsContainer
    $data.DomainControllersContainer            = $domain.DomainControllersContainer
    $data.ForeignSecurityPrincipalsContainer    = $domain.ForeignSecurityPrincipalsContainer
    $data.LostAndFoundContainer                 = $domain.LostAndFoundContainer
    $data.QuotasContainer                       = $domain.QuotasContainer
    $data.SystemsContainer                      = $domain.SystemsContainer
    $data.UsersContainer                        = $domain.UsersContainer
    $data.PartitionsContainer                   = $forest.PartitionsContainer
    $data.configurationNamingContext            = $rootDse.configurationNamingContext
    $data.DsServiceName                         = $rootDse.dsServiceName
    $data.OptionalFeatures                      = (Get-fnOptionalFeatures) -join ","
    $data.SpnSuffixes               = Get-fnSpnSuffixes -Forest $forest

    $data.DomainCount                           = ($forest.Domains).Count
    $data.SiteCount                             = ($forest.Sites).Count
    
    
    $data.TrustedDomainObjects          = Get-fnTrustedObjects
    $data.DomainAthenticationPolicy     = Get-fnDomainAuthPolicy
    $data.DomainAthenticationPolicySilo = Get-fnDomainAuthPolicySilo
    $data.DomainCentralAccesPolicy      = Get-fnDomainCentralAccessPolicy
    $data.DomainCentralAccessRule       = Get-fnDomainCentralAccessRule
    $data.DomainClaimTransformPolicy    = Get-fnDomainClaimTransformPolicy

    <# Objects not in stored in database right now. Need to think how to save them. possible option
    1. loop through them flatten it and stored in one row
    2. multiple rows
    3. separate table
    #>
    
    $data.DomainClaimType               = Get-fnDomainClaimType
    
    $data.Subnets                   = Get-fnSubets
    $data.UpnSuffixes               = Get-fnUpnSuffixes -Forest $forest
    $data.ReplicationSiteLinks      = Get-fnReplicationSiteLinks
    
    $data.Sites                     = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
    $data.PasswordPolicy            = Get-fnPasswordPolicy 
    
    $data.DnsSrv                        = (Get-fnDnsData -domain $domain.DNSRoot).SRV    
    $data.DnsA                          = (Get-fnDnsData -domain $domain.DNSRoot).A

    return $data
}
# Get-fnActiveDirectory
