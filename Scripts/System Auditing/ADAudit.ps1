<#
.SYNOPSIS
This script performs an audit of the AD configuration. 
.DESCRIPTION
This script outputs all of the relevant information about the configuration of an Active Directory environment including DNS. 
.EXAMPLE
ADAudit.ps1
.NOTES
#>

write-host "Forest Mode:"
(Get-ADForest).ForestMode
write-host "Domain Mode:"
(Get-ADDomain).DomainMode
write-host "Domain Name"
(Get-ADDomain).DistinguishedName
write-host "Default Computers OU"
(Get-ADDomain).ComputersContainer
write-host "Default Users OU"
(Get-ADDomain).UsersContainer
write-host "FSMO Holders"
write-host (Get-ADDomain | Select InfrastructureMaster, RIDMaster, PDCEmulator)
write-host (Get-ADForest | Select DomainNamingMaster, SchemaMaster)
write-host "DNS Servers:"
$NS = Resolve-DnsName -Name (Get-ADDomain).DNSRoot -Type NS | `
    Where {$_.Type -eq 'NS'} | `
    Select-Object -ExpandProperty NameHost
foreach ($server in $NS)
{
    write-host $server
    }
write-host "Forwaders:"
$output = foreach ($server in $NS) {
    $forwarders = Get-DNSServer -ComputerName $server | `
                  Select-Object -ExpandProperty ServerForwarder | `
                  Select-Object -ExpandProperty IPAddress | `
                  Select-Object -ExpandProperty IPAddressToString

    foreach ($forwarder in $forwarders) {
        $props = @{'DNSServer' = (Resolve-DNSName -Name $server).Name ; 
                   'Forwarder' = $forwarder}
        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
    }
}
write-host "Optional AD Features:"
write-host (Get-ADOptionalFeature -Filter * | select DistinguishedName)
write-host "DNS Server Scavenging"
foreach ($server in $NS) {
write-host "Server " $server
Get-DnsServerScavenging -ComputerName $server
}
write-host "DNS Zone Scavenging"
$Zones = Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False -and $_.ZoneName -ne 'TrustAnchors'}
$Zones | Get-DnsServerZoneAging
write-host "Reverse Lookup Zones"
write-host (Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False -and $_.ZoneName -ne 'TrustAnchors' -and $_.IsReverseLookupZone -eq $true} | select ZoneName)
write-host "AD Sites and Subnets"
$sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
foreach ($Site in $Sites) {            

 $obj = New-Object -Type PSObject -Property (            
  @{            
   "SiteName"  = $site.Name;            
   "SubNets" = $site.Subnets;            
   "Servers" = $Site.Servers            
  }            
 )            
 $Obj            
}