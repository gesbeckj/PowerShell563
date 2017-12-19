Configuration DINO-File1 {
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
    [String[]] $DNSServers

    )
    Import-DscResource -Module xSystemSecurity, xTimeZone
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xComputerManagement

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
                DomainName = $DomainName
                Credential = $DomainAdminCredential
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
            WindowsFeature RSAT-Clustering
            {
                Name = "RSAT-Clustering"
                Ensure = "Present"
                IncludeAllSubFeature = $True
            }    
            WindowsFeature Failover-Clustering
            {
                Name = "Failover-Clustering"
                Ensure = "Present"
                IncludeAllSubFeature = $True
                DependsOn = "[WindowsFeature]RSAT-Clustering"
            }  
            WindowsFeature FS-FileServer
            {
                Name = "FS-FileServer"
                Ensure = "Present"
                IncludeAllSubFeature = $True
                DependsOn = "[WindowsFeature]Failover-Clustering"
            }      
    }
}
