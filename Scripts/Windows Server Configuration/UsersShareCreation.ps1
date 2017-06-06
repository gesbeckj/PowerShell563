<#
.SYNOPSIS
This creates a folder for user shares. 
.DESCRIPTION
This creates a folder for user shares. 
.EXAMPLE
UsersShareCreation.ps1 -Folder "C:\Users\"
.NOTES
Must run as Domain Admin
#>
[CmdletBinding()]
param (
#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string]$folder
)



new-item $folder -ItemType directory
$acl = Get-Acl $folder
$acl.SetAccessRuleProtection($true,$true)
set-acl -Path $folder -AclObject $acl
$acl = get-acl -Path $folder
$acl | select -ExpandProperty Access | Where{$_.IdentityReference -eq "BUILTIN\Users"} | foreach{$acl.RemoveAccessRule($_)}
$group =  New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
$acl.SetGroup($group)
set-acl -Path $folder -AclObject $acl
$authgroup =  New-Object System.Security.Principal.NTAccount("Builtin", "Authenticated Users")
$colRights = [System.Security.AccessControl.FileSystemRights]"Read,ExecuteFile,ListDirectory,ReadAndExecute"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Authenticated Users", "ReadAndExecute, Synchronize","None" ,"None","Allow")
$acl = get-acl $folder
$acl.AddAccessRule($accessRule)
set-acl $folder -acl $acl
new-smbshare -name "Users" -Path $folder -FullAccess $domainAdmin, "Authenticated Users", "SYSTEM" 