$ADComputers = Get-ADComputer -Filter * -Properties * | Where-Object {$_.OperatingSystem -NotLike "*Server*"}
foreach ($ADComputer in $ADComputers)
{
Write-Output ("Installing Full SSM Suite on: " + $ADComputer.DNSHostName)
$computerName = '\\' + $ADComputer.Name
Invoke-Command {C:\Bin\PsExec.exe $computerName dsregcmd /leave} -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue 
}