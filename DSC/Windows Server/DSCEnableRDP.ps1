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

Configuration EnableRDP {
param(
#ComputerName
[string[]]$ComputerName="localhost"
)

Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
Import-DscResource -ModuleName xPSDesiredStateConfiguration

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
        xServiceSet TermServ
        {
            Name = "TermService"
            StartupType = "Automatic"
            State = "Running"
            Ensure = "Present"
        }
}
}
EnableRDP -ComputerName $ComputerName -OutputPath $path
