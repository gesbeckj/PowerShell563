$ADComputers = Get-ADComputer -Filter * -Properties * | Where-Object {$_.OperatingSystem -NotLike "*Server*"}
foreach ($ADComputer in $ADComputers)
{
Write-Output ("Installing Full SSM Suite on: " + $ADComputer.DNSHostName)
$computerName = '\\' + $ADComputer.Name
Invoke-Command {Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider\Servers\SW-DC2\" -Recurse} -ErrorAction SilentlyContinue -WarningAction SilentlyContinue 
}