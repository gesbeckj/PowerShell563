<#
.SYNOPSIS
This script configures a server to a base set of standards. 
.DESCRIPTION
The base standards include enabling RDP, enabling Windows File Sharing, Setting Windows Update to Download Only, Disabling IE Enhance Security, Error Reporting and Customer Improvement Program.
.EXAMPLE
ServerDefault.ps1
.NOTES
No Parameters
#>

#Enable RDP
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" 

#Download but do not install updates
set-itemproperty –Path ‘HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU’ –name “AUOptions” –Value 3

#Disable IE Enhanced Security
set-itemproperty –Path ‘HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}’ –name “IsInstalled” –Value 0
set-itemproperty –Path ‘HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}’ –name “IsInstalled” –Value 0

#Disable Windows Error Reporting
Disable-WindowsErrorReporting

#Disable Customer Improvement Program
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0

#Enable Windows File Sharing
netsh advfirewall firewall set rule group=”File and Printer Sharing” new enable=Yes

#Disable Feedback
if(!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'))
{
new-item 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'
}
New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod' -Value 0 -PropertyType DWord