<#
.SYNOPSIS
This adds a UPN suffix to an AD Forest.
.DESCRIPTION
This adds a UPN suffix to an AD Forest. 
.EXAMPLE
AddUPNSuffix.ps1 -UPNSuffix "Avengers.com"
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]
param(
#UPN Suffix
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $UPNSuffix
)

Get-AdForest | Set-AdForest -UPNSuffixes @{Add=$UPNSuffix} -Identity 