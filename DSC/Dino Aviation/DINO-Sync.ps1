Configuration DINO-Sync {
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
    [string]$InterfaceAlias="Ethernet"


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
                State          = 'Enabled'
                InterfaceAlias = 'Ethernet'
                AddressFamily  = 'IPv4'
            }
            xDhcpClient DisableDhcpClient6
            {
                State          = 'Disabled'
                InterfaceAlias = 'Ethernet'
                AddressFamily  = 'IPv6'
            }

            WindowsFeature ADDSTools
            {
                Ensure = "Present"
                Name = "RSAT-ADDS-Tools"
            }
    }
}
