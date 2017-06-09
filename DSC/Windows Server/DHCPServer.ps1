<#
.SYNOPSIS
This creates a MOF file for DSC for configuring DHCP on a domain controller
.DESCRIPTION
This accepts the parameters that you would need to configure DHCP. It does not currently support failover. 
.EXAMPLE
DHCPServer.ps1 -ComputerName 'Server' -DHCPNetworkID '192.168.1.0' -StartRange '192.168.1.50' -EndRange '192.168.1.250' -DNSServers '192.168.1.5' -Gateway '192.168.1.1' -DomainName 'contoso.com' -DHCPReservationsCSV c:\reservations.csv
.NOTES
IPv4 only and requires Domain Admin for authorizing the DHCP Server. 

CSV File should look like:
Name,MACAddress,IPAddress
Netgear Switch,a0639196ce1e,192.168.1.209
#>
[CmdletBinding()]
param(
#ComputerName
[string[]]$ComputerName="localhost",

#NetworkID
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$DHCPNetworkID,

#PrefixLength
[uint32]$PrefixLength="24",

#Duration in days
[uint32]$Duration="8",

#ScopeName
[string]$ScopeName="DHCP-Scope",

#StartRange
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$StartRange,

#EndRange
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$EndRange,

#DNS Servers
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string[]]$DNSServers,

#Gateway
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$Gateway,

#Domain Name
[ValidateNotNullOrEmpty()]
[string]$DomainName,

#DHCPReservations CSV File
[string]$DHCPReservationCSV,

#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)


Configuration DSCDHCPServer
{
param(
#ComputerName
[string[]]$ComputerName="localhost",

#NetworkID
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$DHCPNetworkID,

#PrefixLength
[uint32]$PrefixLength="24",

#Duration in days
[uint32]$Duration="8",

#ScopeName
[string]$ScopeName="DHCP-Scope",

#StartRange
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$StartRange,

#EndRange
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$EndRange,

#DNS Servers
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string[]]$DNSServers,

#Gateway
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$Gateway,

#Domain Name
[ValidateNotNullOrEmpty()]
[string]$DomainName,

#DHCPReservations CSV File
[string]$DHCPReservationCSV
)
Import-DscResource -ModuleName xDHCPServer
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1

    node $ComputerName
    {
        WindowsFeature DHCP
        {
            Ensure = "Present"
            Name = "DHCP"

        }
        xDhcpServerAuthorization LocalServerActivation
        {
            Ensure = 'Present'
        }
    [IPAddress]$ip = 0
    $ip.Address = ([UInt32]::MaxValue) -shl (32 - $PrefixLength) -shr (32 - $PrefixLength)
    xDhcpServerScope Scope
    {
        Ensure = 'Present'
        IPEndRange = $EndRange
        IPStartRange = $StartRange
        Name = $ScopeName
        SubnetMask = $ip.toString()
        LeaseDuration = ((New-TimeSpan -days 8 ).ToString())
        State = 'Active'
        AddressFamily = 'IPv4'
        
    }
    xDhcpServerOption ScopeOptions
    {
        Router = $Gateway
        Ensure = 'Present'
        ScopeID = $DHCPNetworkID
        DnsServerIPAddress = $DNSServers
        DnsDomain = $DomainName
    }
    $DHCPReservations = import-csv $DHCPReservationCSV
    foreach ($Reservation in $DHCPReservations)
    {
           xDhcpServerReservation $Reservation.Name
           {
                ScopeID = $DHCPNetworkID
                IPAddress = $Reservation.IPAddress
                Name = $Reservation.Name
                Ensure = 'Present'
                ClientMACAddress = $Reservation.MACAddress
           }
    }
    }
}

DSCDHCPServer -ComputerName $ComputerName -OutputPath $path -DHCPNetworkID $DHCPNetworkID -PrefixLength $PrefixLength -ScopeName $ScopeName -StartRange $StartRange -EndRange $EndRange -Duration $Duration -Gateway $Gateway -DNSServers $DNSServers -DomainName $DomainName -DHCPReservationCSV $DHCPReservationCSV