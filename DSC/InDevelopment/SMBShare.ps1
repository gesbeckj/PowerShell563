Configuration DSCSMBShare
{
param(
#ComputerName
[string[]]$ComputerName="localhost",

#Domain Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $DomainName,

#Company Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $CompanyName,

#NetBIOS Name
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $NetBIOSDomainName,

#ShareNames
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string[]]$Shares
)
Import-DscResource -ModuleName xSystemSecurity
Import-DscResource -ModuleName xSMBShare
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Import-DscResource -Module xActiveDirectory
    node $ComputerName
    {
        WindowsFeature FileSharing
        {
            Ensure = "Present"
            Name = "FS-FileServer"
        }
        file RootFolder
        {
            DestinationPath = "D:\Shared Data"
            Ensure = 'Present'
            Type = 'Directory'
        }
        $splitDomain = $domainName.Split(".")
        $GroupPath = "OU=" + "Security Groups" + ",OU=" + $CompanyName + ",DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]

        foreach ($share in $shares)
        {
            File ($share + "Folder")
            {
                DestinationPath = "D:\Shared Data\" + $share
                Type = 'Directory'
                Ensure = 'Present'
            }
            Script ($share + "Inherit")
            {
                SetScript = 
                {
                    $folder = "D:\Shared Data\" + $using:share
                    $acl = Get-Acl $folder
                    $acl.SetAccessRuleProtection($true,$true)
                    set-acl -Path $folder -AclObject $acl
                }
                TestScript =
                {
                    $folder = "D:\Shared Data\" + $using:share
                    $acl = Get-Acl $folder
                    return $acl.AreAccessRulesProtected
                }
                GetScript = {
                    # Do Nothing
                    
                }
            }
            xADGroup ($share + "Group")
            {
                GroupName = $share
                Path = $GroupPath
            }
            xFileSystemAccessRule ($share + "ACL" + "ShareGroup")
            {
                Path = "D:\Shared Data\" + $share
                Identity = $NetBIOSDomainName + "\" + $share
                Ensure = 'Present'
                Rights = 'FullControl'
            }
            xFileSystemAccessRule ($share + "ACL" + "Admin")
            {
                Path = "D:\Shared Data\" + $share
                Identity = "Administrator"
                Rights = 'FullControl'
            }
            xFileSystemAccessRule ($share + "ACL" + "Everyone")
            {
                Path = "D:\Shared Data\" + $share
                Identity = "Everyone"
                Ensure = 'Absent'
            }
            xFileSystemAccessRule ($share + "ACL" + "Authenticated")
            {
                Path = "D:\Shared Data\" + $share
                Identity = "NT Authority\Authenticated Users"
                Ensure = 'Absent'
            }
            xFileSystemAccessRule ($share + "ACL" + "Domain")
            {
                Path = "D:\Shared Data\" + $share
                Identity = $NetBIOSDomainName + "\Domain Users"
                Ensure = 'Absent'
            }
             xFileSystemAccessRule ($share + "ACL" + "Users")
            {
                Path = "D:\Shared Data\" + $share
                Identity = 'BUILTIN\Users'
                Ensure = 'Absent'
            }
            xSmbShare ($share + "SMB")
            {
                Ensure =  'Present'
                Path = "D:\Shared Data\" + $share
                ChangeAccess = $share
                Name = $share
            }

        }


    }
}