$BackupPolicy = New-WBPolicy
$VM = Get-WBVirtualMachine | Where-Object {$_.VMName -eq "MCF-OFC-Mitchell" -or $_.VMName -eq "MCF-OFC-TS1" -or $_.VMName -eq "MCF-OFC-File" -or $_.VMName -eq "Permar"}
$VM = Get-WBVirtualMachine | Where-Object {$_.VMName -eq "MCF-MFG-PDM" -or $_.VMName -eq "MCF-FabSuite" -or $_.VMName -eq "Accrotimeserver"}
Add-WBVirtualMachine -Policy $BackupPolicy -VirtualMachine $VM
$Disk = Get-WBDisk | Where-Object {$_.DiskNumber -eq 2}
$Target = New-WBBackupTarget -Disk $Disk -PreserveExistingBackups $false
Add-WBBackupTarget -policy $BackupPolicy -target $Target  -force
$sch2 = [datetime]"01/31/2011 21:00:00"
Set-WBSchedule -policy $BackupPolicy -schedule $sch2
Set-WBPolicy -Policy $BackupPolicy
Start-WBBackup -Policy $BackupPolicy
Remove-WBPolicy $BackupPolicy -Force