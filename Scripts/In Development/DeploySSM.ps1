#Required Meraki.msi, Mep.msi and Symantec.exe to existing in C:\bin. Also requires PsExec.exe to exist in C:\bin. 
#Must be run with domain admin credentials. 

#Installs full suite on workstations. 
$ADComputers = Get-ADComputer -Filter * -Properties * | Where-Object {$_.OperatingSystem -NotLike "*Server*"}
foreach ($ADComputer in $ADComputers)
{
Write-Output ("Installing Full SSM Suite on: " + $ADComputer.DNSHostName)
$computerName = '\\' + $ADComputer.Name
Copy-Item -Path C:\Bin\Meraki.msi -Destination "$computerName\c$\Meraki.msi" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Invoke-Command {C:\Bin\PsExec.exe $computerName msiexec /i "C:\Meraki.msi"} -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Copy-Item -Path C:\Bin\Mep.msi -Destination "$computerName\c$\Mep.msi" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Invoke-Command {C:\Bin\PsExec.exe $computerName msiexec /i "C:\Mep.msi"} -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Copy-Item -Path C:\Bin\Sym.exe -Destination "$computerName\c$\Sym.exe" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Invoke-Command {C:\Bin\PsExec.exe $computerName C:\Sym.exe -silent}
}

#Installs only Symantec on servers
$ADServers = Get-ADComputer -Filter * -Properties * | Where-Object {$_.OperatingSystem -Like "*Server*"}
foreach ($ADComputer in $ADServers)
{
Write-Output ("Installing Symantec Only on: " + $ADComputer.DNSHostName)
$computerName = '\\' + $ADComputer.Name
Copy-Item -Path C:\Bin\Sym.exe -Destination "$computerName\c$\Sym.exe" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
Invoke-Command {C:\Bin\PsExec.exe $computerName C:\Sym.exe -silent}
}