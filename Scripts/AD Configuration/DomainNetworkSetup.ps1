<#
.SYNOPSIS
This script configures the networking, DHCP and DNS for an existing Domain Controller. 
.DESCRIPTION
This script configures the networking, DHCP and DNS for an existing Domain Controller. It removes all forwarders and configures DNS Aging/Scavenging. 
.EXAMPLE
DomainNetworkSetup.ps1 -DHCPStart "192.168.1.100" -DHCPEnd "192.168.1.200" -GWIP "192.168.1.1" -SubnetName "My Subnet" -NetworkID "192.168.1.0/24" -IP "192.168.1.5"
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]
param (
#DHCP Start IP Address
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$DHCPStart,
#DHCP End IP Address
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$DHCPEnd,
#Gateway IP Address
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$GWIP,
#Name for the Subnet
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$SubnetName,
#Network ID (e.g. 192.168.14.0/24)
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$NetworkID,
#IP Address for the server
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$ip
)

New-NetIPAddress -InterfaceAlias Ethernet -IPAddress $ip -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1
Get-NetAdapter | New-NetRoute -DestinationPrefix "0.0.0.0/0" -NextHop $GWIP
New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
New-NetFirewallRule –DisplayName “Allow ICMPv4-Out” –Protocol ICMPv4 –Direction Outbound
Set-DnsServerScavenging -ScavengingState $true  -ScavengingInterval "7.00:00:00"
Install-WindowsFeature DHCP -IncludeManagementTools
Netsh DHCP Add SecurityGroups
Restart-Service DhcpServer
Add-DhcpServerInDC -DnsName "$env:computername.$env:userdnsdomain"
Add-DhcpServerv4Scope -name $SubnetName -StartRange $DHCPStart -EndRange $DHCPEnd -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -DnsDomain $env:userdnsdomain -DnsServer $ip -Router $GWIP
Add-DnsServerPrimaryZone -NetworkID $NetworkID -ReplicationScope "Forest" 
get-dnsserverzone | Set-DnsServerZoneAging -Aging $true -ErrorAction SilentlyContinue
Get-DnsServerForwarder | Remove-DNSServerForwarder -force -erroraction SilentlyContinue