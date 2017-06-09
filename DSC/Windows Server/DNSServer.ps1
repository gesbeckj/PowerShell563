<#
.SYNOPSIS
This configures DNS for a Windows Domain Controller
.DESCRIPTION
This sets up the DNS Server to not use forwarders, to enable scavenging and aging and to use RDNS for all specified IP schemes.
.EXAMPLE
DNSServer.ps1 -ComputerName 'Server' -DomainName 'Contoso.com' -RDNSSubnets '192.168.1.0'
.NOTES
IPv4 Only and requires Domain Admin as it runs on a Domain Controller. 
#>
[CmdletBinding()]
param(
#ComputerName
[string[]]$ComputerName="localhost",

#DomainName
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$domainName,

#RNDS
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String[]] $RDNSSubnets,
#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)

Configuration DSCWindowsServerDNS
{
param(
#ComputerName
[string[]]$ComputerName="localhost",

#DomainName
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$domainName,

#RNDS
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String[]] $RDNSSubnets
)
Import-DscResource -ModuleName xDnsServer
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    node $ComputerName
    {
        xDnsServerForwarder RemoveAllForwarders
        {
                IsSingleInstance = 'Yes'
                IPAddresses = @()
        }
        xDnsServerADZone localDomain
        {
            Name = $domainName
            DynamicUpdate = 'Secure'
            ReplicationScope = 'Forest'
            Ensure = 'Present'
        }
        Script scavengingRootZone
        {
            SetScript = 
            {
                    get-dnsserverzone -name $using:domainName | Set-DnsServerZoneAging -Aging $true -RefreshInterval "7.00:00:00" -NoRefreshInterval "7.00:00:00" -ErrorAction SilentlyContinue
            }
            TestScript =
            {
                return  (  ((get-dnsserverzone -name $using:domainName | get-dnsserverzoneaging).RefreshInterval.ToString() -eq '7.00:00:00') -and ((get-dnsserverzone -name $domainName | get-dnsserverzoneaging).NoRefreshInterval.ToString() -eq '7.00:00:00') -and ((get-dnsserverzone -name $domainName | get-dnsserverzoneaging).AgingEnabled.ToString() -eq 'True') )
            }
            GetScript = {
                # Do Nothing
            }
        }

        foreach ($subnet in $RDNSSubnets)
        {
            $split = $subnet.Split(".")
            $RDNSZone = $split[2] + "." + $split[1] + "." + $split[0] + ".in-addr.arpa"
            xDnsServerADZone $Subnet
            {
                Name = $RDNSZone
                DynamicUpdate = 'Secure'
                ReplicationScope = 'Forest'
                Ensure = 'Present'
            }
            Script $RDNSZone
            {
                SetScript = 
                {
                        get-dnsserverzone -name ($using:RDNSZone).toString() | Set-DnsServerZoneAging -Aging $true -RefreshInterval "7.00:00:00" -NoRefreshInterval "7.00:00:00" -ErrorAction SilentlyContinue
                }
                TestScript =
                {
                    return  (  ((Get-DnsServerZone -name ($using:RDNSZone).toString() | get-dnsserverzoneaging).RefreshInterval.ToString() -eq '7.00:00:00') -and ((get-dnsserverzone -name ($using:RDNSZone).toString() | get-dnsserverzoneaging).NoRefreshInterval.ToString() -eq '7.00:00:00') -and ((get-dnsserverzone -name ($using:RDNSZone).toString() | get-dnsserverzoneaging).AgingEnabled.ToString() -eq 'True') )
                }
                GetScript = {
                    # Do Nothing
                    
                }
            }
        }
        Script setServerScavenging
        {
            SetScript = 
            {
                    Set-DnsServerScavenging -ScavengingState $true  -ScavengingInterval "7.00:00:00" -RefreshInterval "7.00:00:00" -NoRefreshInterval "7.00:00:00"
            }
            TestScript =
            {
                return ( ((Get-DnsServerScavenging).RefreshInterval.ToString() -eq '7.00:00:00') -and ((Get-DnsServerScavenging).ScavengingInterval.ToString() -eq '7.00:00:00') -and ((Get-DnsServerScavenging).NoRefreshInterval.ToString() -eq '7.00:00:00') -and ((Get-DnsServerScavenging).Scavengingstate.ToString() -eq 'True') )
            }
            GetScript = {
                # Do Nothing
            }
        }
    }
}


DSCWindowsServerDNS -ComputerName $ComputerName -OutputPath $path -domainName $domainName -RDNSSubnets $RDNSSubnets