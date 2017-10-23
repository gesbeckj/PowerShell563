Configuration SQLServer {
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
[System.Management.Automation.PSCredential]
$SqlServiceCredential,

[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.PSCredential]
$SqlAgentServiceCredential,

[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.PSCredential]
$SqlAdministratorCredential,

[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[String]
$DomainName
)

Import-DscResource -Module xSystemSecurity, xTimeZone
Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Import-DscResource -ModuleName xPSDesiredStateConfiguration, xComputerManagement
Import-DscResource -ModuleName xSQLServer, xActiveDirectory

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
            DomainName = $DomainName
            Credential = $DomainAdminCredential
            Name = "MGMT-SQL-00"
        }
        WindowsFeature "RSAT-AD-PowerShell"
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }
        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
        }
        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }
        xADUser SQLAdminUser
        {
            DomainAdministratorCredential = $DomainAdminCredential
            UserName = "sqladmin"
            Ensure = "Present"
            Password = $SqlAdministratorCredential
            DomainName = $DomainName
        }
        xADUser SQLServiceUser
        {
            DomainAdministratorCredential = $DomainAdminCredential
            UserName = "sqlserviceuser"
            Ensure = "Present"
            Password = $SqlServiceCredential
            DomainName = $DomainName
        }
        xADUser SQLAgentServiceUser
        {
            DomainAdministratorCredential = $DomainAdminCredential
            UserName = "sqlagentserviceuser"
            Ensure = "Present"
            Password = $SqlAgentServiceCredential
            DomainName = $DomainName
        }
        xADGroup SQLAdminGroup
        {
            GroupName = 'SQL Administrators'
            DomainController = 'MGMT-DC'
            Credential = $DomainAdminCredential
        }
        xSQLServerSetup SQLSetup
        {
            InstanceName = "SYSTEMCENTER"
            SourcePath = "\\mgmt-storage.mgmt.local\Repository\SQL2016\"
            #Features = 'SQLENGINE,AS'
            Features = 'SQLENGINE,FULLTEXT,RS'
            SQLCollation = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount = $SqlServiceCredential
            AgtSvcAccount = $SqlAgentServiceCredential
            #ASSvcAccount = $SqlServiceCredential
            SQLSysAdminAccounts   = 'MGMT\SQL Administrators', $SqlAdministratorCredential.UserName
            #ASSysAdminAccounts    = 'MGMT\SQL Administrators', $SqlAdministratorCredential.UserName
            BrowserSvcStartupType = 'Automatic'
            UpdateEnabled = $True

            InstallSharedDir      = 'E:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir   = 'E:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir           = 'E:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir     = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Data'
            SQLUserDBDir          = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Data'
            SQLUserDBLogDir       = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Data'
            SQLTempDBDir          = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Data'
            SQLTempDBLogDir       = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Data'
            SQLBackupDir          = 'E:\Program Files\Microsoft SQL Server\MSSQL13.SYSTEMCENTER\MSSQL\Backup'
            #ASConfigDir           = 'D:\MSOLAP13.SYSTEMCENTER\Config'
            #ASDataDir             = 'D:\MSOLAP13.SYSTEMCENTER\Data'
            #ASLogDir              = 'D:\MSOLAP13.SYSTEMCENTER6\Log'
            #ASBackupDir           = 'D:\MSOLAP13.SYSTEMCENTER\Backup'
            #ASTempDir             = 'D:\MSOLAP13.SYSTEMCENTER\Temp'

            DependsOn = '[xADGroup]SQLAdminGroup', '[xADUser]SQLAdminUser', '[WindowsFeature]NetFramework45', '[WindowsFeature]NET-Framework-Core', '[xADUser]SQLServiceUser', '[xADUser]SQLAgentServiceUser'
        }
        xSQLServerFirewall SQLFirewall
        {
            DependsOn = '[xSQLServerSetup]SQLSetup'
            Features = 'SQLENGINE,FULLTEXT,RS'
            InstanceName = "SYSTEMCENTER"
            SourcePath = "\\mgmt-storage.mgmt.local\Repository\SQL2016\"
        }
}
}