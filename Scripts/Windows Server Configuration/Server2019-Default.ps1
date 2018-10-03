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

#Disable Windows Error Reporting
Disable-WindowsErrorReporting

#Disable Customer Improvement Program
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0

#Enable Windows File Sharing
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

