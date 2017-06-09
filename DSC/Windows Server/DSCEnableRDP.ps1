<#
.SYNOPSIS
This creates a MOF file for DSC for enabling Remote Desktop.
.DESCRIPTION
This creates a MOF file for DSC for enabling Remote Desktop.
.EXAMPLE
DSCEnableRDP.ps1 -ComputerName 'Server' -outputpath C:\DSC\
#>
[CmdletBinding()]
param(
#ComputerName
[string[]]$ComputerName="localhost",

#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)

Configuration DSCEnableRDP {
param(
#ComputerName
[string[]]$ComputerName="localhost"
)

Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Node $ComputerName
{
        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'NonSecure'
        }

        xFirewall AllowRDP
        {
            DisplayName = 'DSC - Remote Desktop Admin Connections'
            Name = "Remote Desktop"
            Ensure = 'Present'
            Enabled = 'True'
        }
}
}
DSCEnableRDP -ComputerName $ComputerName -OutputPath $path
