<#
.SYNOPSIS
This configures a Windows Domain Controller
.DESCRIPTION
This sets up a Domain Controller. It configures the OUs under Company with an OU for Users, Groups and Computers. It also re-directs the default Users and Computers OU
.EXAMPLE
DSCADInstall.ps1 -ComputerName 'Server' -DomainName 'Contoso.com' -NetBIOSDomainName 'CONTOSO' -SafeModeAdministratorCred $SafeModeCred -DomainCred $DomainCred -CompanyName "Contoso LLC" -Path "C:\DSC"
.NOTES
Requires Domain Admin as it runs on a Domain Controller. 
#>
[CmdletBinding()]
param(

#ComputerName
[string[]]$ComputerName="localhost",

#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $DomainName,

#NetBIOS Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $NetBIOSDomainName,

#Safe Mode Password
[Parameter(Mandatory)]
[pscredential]$safemodeAdministratorCred,

#Domain Cred
[Parameter(Mandatory)]
[pscredential]$domainCred,

#Company Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $CompanyName,

#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path,

#Configuration Data
[hashtable]$cd
)

Configuration DSCADInstall {
param(

#ComputerName
[string[]]$ComputerName="localhost",

#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $DomainName,

#NetBIOS Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $NetBIOSDomainName,

#Safe Mode Password
[Parameter(Mandatory)]
[pscredential]$safemodeAdministratorCred,

#Domain Cred
[Parameter(Mandatory)]
[pscredential]$domainCred,

#Company Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $CompanyName
)

Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Import-DscResource -Module xActiveDirectory
Node $Computername
{        
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"

        }
        WindowsFeature ADTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS"

        }
        WindowsFeature DHCPTools
        {
            Ensure = "Present"
            Name = "RSAT-DHCP"

        }
        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DomainNetbiosName = $NetBIOSDomainName
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential = $domainCred
            RetryCount = 60
            RetryIntervalSec = 60
            DependsOn = "[xADDomain]FirstDS"
        }
        xADRecycleBin RecycleBin
        {
            EnterpriseAdministratorCredential = $domainCred
            ForestFQDN = $DomainName
        }
        $splitDomain = $domainName.Split(".")
        $DCPath = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
        xADOrganizationalUnit CompanyOU
        {
            
            Name = $CompanyName
            Path = $DCPath
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
        }
        $CompanyPath = "OU=" + $CompanyName + "," + $DCPath
        xADOrganizationalUnit UsersOU
        {
            Name = "Users"
            Path = $CompanyPath
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
            DependsOn = "[xADOrganizationalUnit]CompanyOU"
        }
        xADOrganizationalUnit ComputersOU
        {
            Name = "Computers"
            Path = $CompanyPath
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
            DependsOn = "[xADOrganizationalUnit]CompanyOU"
        }
        xADOrganizationalUnit SecurityGroupsOU
        {
            Name = "Security Groups"
            Path = $CompanyPath
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
            DependsOn = "[xADOrganizationalUnit]CompanyOU"
        }
        Script redirectUsers
        {
            DependsOn = "[xADOrganizationalUnit]UsersOU"
            SetScript = 
            {
                    redirusr ("OU=Users," + $using:CompanyPath)
            }
            TestScript =
            {
                return ((Get-ADDomain).UsersContainer.toString() -eq ("OU=Users," + $using:CompanyPath))
            }
            GetScript = {
                # Do Nothing
            }
        }
        Script redirectComputers
        {
            DependsOn = "[xADOrganizationalUnit]ComputersOU"
            SetScript = 
            {
                    redircmp ("OU=Computers," + $using:CompanyPath)
            }
            TestScript =
            {
                return ((Get-ADDomain).ComputersContainer.toString() -eq ("OU=Computers," + $using:CompanyPath))
            }
            GetScript = {
                # Do Nothing
            }
        }     
}
}
DSCADInstall -ComputerName $ComputerName -OutputPath $path -domainName $domainName -SafeModeAdministratorCred $safemodeAdministratorCred -DomainCred $DomainCred -NetBIOSDomainName $NetBIOSDomainName -CompanyName $CompanyName -ConfigurationData $cd