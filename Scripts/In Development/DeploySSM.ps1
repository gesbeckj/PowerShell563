$ADComputers = Get-ADComputer -filter * 
foreach ($ADComputer in $ADComputers)
{
Write-Output $ADComputer.DNSHostName
$computerName = '\\' + $ADComputer.Name

Copy-Item -Path C:\Bin\Meraki.msi -Destination "$computerName\c$\Meraki.msi"
C:\Bin\PsExec.exe $computerName msiexec /i "C:\Meraki.msi"
Copy-Item -Path C:\Bin\Mep.msi -Destination "$computerName\c$\Mep.msi"
C:\Bin\PsExec.exe $computerName msiexec /i "C:\Mep.msi"
}