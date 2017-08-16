Configuration MGMTSQL {
param(
#ComputerName
[string[]]$ComputerName="localhost",

#Domain Admin Credential
[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.PSCredential]
$DomainAdminCredential
)

Import-DscResource -Module xSystemSecurity, xTimeZone
Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Import-DscResource -ModuleName xPSDesiredStateConfiguration, xComputerManagement
Import-DscResource -ModuleName xSQLServer

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
        xComputer JoinDomain
       { 
            DomainName = "management.local"
            Credential = $DomainAdminCredential
            Name = "MGMT-SQL"
        }
         WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
        }

}
}