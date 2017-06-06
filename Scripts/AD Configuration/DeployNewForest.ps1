<#
.SYNOPSIS
This promotes a server to become a new domain controller in a new Forest. 
.DESCRIPTION
This promotes a server to become a new domain controller in a new Forest. 
.EXAMPLE
DeployNewForest.ps1 -DomainName "Avengers.com" -NetBiosName "AVGR" -Credential (Get-Credential)
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]

param (
#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$domainName,
#NetBIOS Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$netbiosName,
#Safe Mode Password Credential
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[pscredential]$Credential
)

# Create the Forest and Domain
Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName $domainName -DomainNetbiosName $netbiosName -ForestMode Win2012R2 -InstallDns -Force -SafeModeAdministratorPassword $Credential.Password -NoRebootOnCompletion