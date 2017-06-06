set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
set-itemproperty –Path ‘HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU’ –name “AUOptions” –Value 3
Disable-WindowsErrorReporting
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0
Dism /online /enable-feature /featurename:SNMP
netsh advfirewall firewall set rule group=”File and Printer Sharing” new enable=Yes
netsh advfirewall firewall add rule name="HP SHM" dir=in protocol=TCP localport=2381 action=allow
netsh advfirewall firewall add rule name="HP SHM" dir=in protocol=TCP localport=2301 action=allow
Mkdir D:\Config
Mkdir D:\VHDs
Mkdir D:\VMs
Set-VMHost -VirtualHardDiskPath 'D:\VHDs' -VirtualMachinePath 'D:\Config’
Set-VMHost -EnableEnhancedSessionMode $true