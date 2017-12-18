Configuration DINO-DC2 {
    param(
    #ComputerName
    [string[]]$ComputerName="localhost",

    #Domain Admin Credential
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [System.Management.Automation.PSCredential]
    $DomainAdminCredential,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [String]
    $DomainName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [String]
    $serverName,

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

    [Int]$RetryCount=20,
    [Int]$RetryIntervalSec=30


    )
    Import-DscResource -Module xSystemSecurity, xTimeZone
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xComputerManagement
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xDnsServer
    Node $ComputerName
    {
            xUAC UAC
            {
                Setting = 'NotifyChanges'
            }
            xIEEsc IEEscAdmin
            {
                UserRole = 'Administrators'
                IsEnabled = $True
            }
            xIEEsc IEEscUsers
            {
                UserRole = 'Users'
                IsEnabled = $True
            }
            xTimeZone TimeZone
            {
                TimeZone = 'Central Standard Time'
                IsSingleInstance = 'Yes'
            }
            xRemoteDesktopAdmin RemoteDesktopSettings
            {
               Ensure = 'Present'
               UserAuthentication = 'Secure'
            }
            xFirewall AllowRDP
            {
                DisplayName = 'DSC - Remote Desktop Admin Connections'
                Name = "Remote Desktop"
                Ensure = 'Present'
                Enabled = 'True'
            }
            xServiceSet TermServ
            {
                Name = "TermService"
                StartupType = "Automatic"
                State = "Running"
                Ensure = "Present"
            }
            xComputer computerName
           {
                Name = $serverName
            }
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
            WindowsFeature ADDSInstall
            {
                Ensure = "Present"
                Name = "AD-Domain-Services"
            }
            WindowsFeature ADDSTools
            {
                Ensure = "Present"
                Name = "RSAT-ADDS-Tools"
                DependsOn = "[WindowsFeature]ADDSInstall"
            }
            xADDomainController ADDomain
            {
                DomainName = $DomainName
                DomainAdministratorCredential = $DomainAdminCredential
                SafemodeAdministratorPassword = $DomainAdminCredential
                DatabasePath = "C:\NTDS"
                LogPath = "C:\NTDS"
                SysvolPath = "C:\SYSVOL"
                DependsOn = "[WindowsFeature]ADDSInstall"
            }
            xDnsServerForwarder RemoveAllForwarders
            {
                    IsSingleInstance = 'Yes'
                    IPAddresses = @()
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
