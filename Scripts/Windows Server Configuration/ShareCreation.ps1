<#
.SYNOPSIS
This script configures network shares based on a CSV. 
.DESCRIPTION
This script configures network shares based on a CSV containing Share Name, Drive Letter and Users. It creates an AD Security Group to control permissions.  
.EXAMPLE
ShareCreation.ps1 -DomainName "Avengers.Com" -CompanyName "Avengers, LLC" -NETBIOSNAME "AVGR" -CSVName "C:\Shares.csv" -ShareDirectory "C:\Shared Data\" 
.NOTES
Must run as Domain Admin as this script creates a Security Group for each Share. 
#>

[CmdletBinding()]
param(
[string]$domainName,
[string]$companyName,
[string]$NETBIOSNAME,
[string]$CSVName,
[string]$ShareDirectory
)


$group =  New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
$splitDomain = $domainName.Split(".")
$DCPath = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
$OUPath = "OU=" + $CompanyName + ",DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
$UsersPath = "OU=Security Groups," + $OUPath
$domainAdmin = $NETBIOSNAME + "\Domain Admins"
$admin = $NETBIOSNAME + "\Administrator"
$shares = Import-Csv $CSVName
New-Item $ShareDirectory -ItemType directory
foreach($share in $shares)
{
    $folder = $ShareDirectory + $share.Share
    new-item $folder -ItemType directory
    new-ADGroup -Name $share.Share -GroupScope Global -Path $UsersPath -Description $share.Letter
    Get-ADGroupMember $share.Share | ForEach-Object{Remove-ADGroupMember $share.share $_ -Confirm:$false}
    $acl = Get-Acl $folder
    $acl.SetAccessRuleProtection($true,$true)
    set-acl -Path $folder -AclObject $acl
    $acl = get-acl -Path $folder
    $acl | select -ExpandProperty Access | Where{$_.IdentityReference -eq "BUILTIN\Users"} | foreach{$acl.RemoveAccessRule($_)}
    $acl.SetGroup($group)
    set-acl -Path $folder -AclObject $acl
    $securityGroup = $NETBIOSNAME + '\' + $share.share
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($securityGroup, "FullControl", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl = get-acl $folder
    $acl.AddAccessRule($accessRule)
    set-acl $folder -acl $acl
    $acl = get-acl $folder
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($admin, "FullControl", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.AddAccessRule($accessRule)
    set-acl $folder -acl $acl
    new-smbshare -name $share.Share -Path $folder -FullAccess $domainAdmin -ChangeAccess $securityGroup 
    foreach($prop in $share.psobject.Properties | select *) 
    {
        if($prop.Value)
        {
            if($prop.Name -eq 'Share')
            {
            }
            elseif ($prop.Name -eq 'Letter')
            {
            }
            else
            {
            Write-Output $prop.Name
            Write-Output $prop.value
            [string]$name = $prop.value.ToString()
            get-aduser -Filter {Name -like $name} | Add-ADPrincipalGroupMembership -MemberOf $share.Share
            }
        }
    }
}