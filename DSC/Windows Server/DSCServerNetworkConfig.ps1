<#
.SYNOPSIS
This creates a MOF file for DSC for configuring a network adapter. 
.DESCRIPTION
This accepts the parameters that you would need to configure a netowrk adapater. It then generates a MOF file that configures a system with those parameters.
.EXAMPLE
DSCServerNetworkConfig.ps1 -IPv4Address 10.10.148.5 -Gateway 10.10.148.1 -DNSServers 10.10.148.5
.EXAMPLE
DSCServerNetworkConfig.ps1 -ComputerName 'Server' -IPv4Address 10.10.148.5 -Gateway 10.10.148.1 -DNSServers 10.10.148.5 -PrefixLengh 16 -InterfaceAlias 'Ethernet 2'
.NOTES
IPv4 only. 
#>
[CmdletBinding()]
param(
#ComputerName defaults to localhost
[string[]]$ComputerName="localhost",
#InterfaceAlias defaults to Ethernet
[string]$InterfaceAlias="Ethernet",
#IPAddress
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $IPv4Address,
#PrefixLength defaults to 24
[uint32]$PrefixLength="24",
#Gateway
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Gateway,
#DNSServers
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String[]] $DNSServers,
#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)

Configuration ServerNetworkConfig {
    param(

    #ComputerName
    [string[]]$ComputerName="localhost",

    #InterfaceAlais
    [string]$InterfaceAlias="Ethernet",

    #IPAddress
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $IPv4Address,

    #PrefixLength
    [uint32]$PrefixLength="24",

    #Gateway
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $Gateway,

    #DNSServers
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String[]] $DNSServers
    )
    Import-DscResource -Module xNetworking
    Node $ComputerName
    {
        xDhcpClient DisableDhcpClient4
        {
            State          = 'Disabled'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
        }
        xDhcpClient DisableDhcpClient6
        {
            State          = 'Disabled'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv6'
        }
        xIPAddress setIPAddress
        {
            IPAddress = $IPv4Address
            InterfaceAlias = $InterfaceAlias
            AddressFamily = "IPv4"
            PrefixLength = $PrefixLength
        }
        xDefaultGatewayAddress setDefaultGateway
        {
            AddressFamily = "IPv4"
            InterfaceAlias = $InterfaceAlias
            Address = $Gateway
            DependsOn = "[xIPAddress]setIPAddress"
        }
        xDNSServerAddress setDNSServer
        {
            InterfaceAlias = $InterfaceAlias
            AddressFamily = "IPv4"
            Address = $DNSServers
            Validate = $false
        }
    }
}
ServerNetworkConfig -ComputerName $ComputerName -InterfaceAlias $InterfaceAlias -IPv4Address $IPv4Address -PrefixLength $PrefixLength -Gateway $Gateway -DNSServers $DNSServers -outputpath $Path