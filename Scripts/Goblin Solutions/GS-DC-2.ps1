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

New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.100.63.6 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.100.63.5,127.0.0.1
Get-NetAdapter | New-NetRoute -DestinationPrefix "0.0.0.0/0" -NextHop 10.100.63.1

Get-WindowsFeature -Name "AD-Domain-Services" | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools
Get-WindowsFeature -Name "DHCP" | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools
Get-WindowsFeature -Name "DNS" | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools

Rename-Computer -NewName "GS-DC-2"
#Restart-Computer

Add-Computer -DomainName "ad.goblinsolutions.tk" -Credential (Get-Credential)

Install-ADDSDomainController -installdns -DomainName "ad.goblinsolutions.tk" -credential (Get-Credential)