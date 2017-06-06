<#
.SYNOPSIS
This performs the initial AD configuration for a new domain.  
.DESCRIPTION
This performs the initial AD configuration for a new domain.  
.EXAMPLE
InitialDomainSetup.ps1 -DomainName "Avengers.com" -CompanyName "Avengers, LLC" -ServicesCredential (Get-Credential)
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]

param (
#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$domainName,
#Company Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$CompanyName,
#Services Credential
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[pscredential]$ServicesCredential
)
Start-Sleep -s 60
$splitDomain = $domainName.Split(".")
$DCPath = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
New-ADOrganizationalUnit -Name $CompanyName -ProtectedFromAccidentalDeletion $true -Path $DCPath
$OUPath = "OU=" + $CompanyName + "," + $DCPath
New-ADOrganizationalUnit -Name "Security Groups" -ProtectedFromAccidentalDeletion $true -path $OUPath
New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $true -path $OUPath
New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $true -path $OUPath
$Identity = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration," + $DCPath
Enable-ADOptionalFeature –Identity $Identity –Scope ForestOrConfigurationSet –Target $domainName -Confirm:$false
$ServicesOU = "CN=Users," + $DCPath
$ServicesIdentity = "CN=Services,CN=Users," + $DCPath
$ServiceName = "Services@" + $domainName
New-ADUser -Name "Services" -Path $ServicesOU -SamAccountName "Services" -Type "User" -UserPrincipalName $ServiceName
Set-ADAccountPassword -Identity $ServicesIdentity -NewPassword $ServicesCredential.Password
Enable-ADAccount -Identity $ServicesIdentity
$userOU = "OU=Users," + $OUPath
$computerOU = "OU=Computer," + $OUPath
redirusr $userou
redircmp $computerOU