<#
.SYNOPSIS
This promotes a server to become a domain controller in an existing Forest. 
.DESCRIPTION
This promotes a server to become a domain controller in an existing Forest. 
.EXAMPLE
DCPromo.ps1 -DomainName "Avengers.Com" -Credential (Get-Credential)
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]
param (
#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$domainName,
#Domain Admin Credentials
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[pscredential]$credential
)
Install-ADDSDomainController -installdns -credential $credential -DomainName $domainName -SafeModeAdministratorPassword $credential.Password -NoRebootOnCompletion