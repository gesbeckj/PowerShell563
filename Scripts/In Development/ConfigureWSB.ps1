$BackupPolicy = New-WBPolicy
$VM = Get-WBVirtualMachine | Where-Object {$_.VMName -eq "MCF-OFC-Mitchell" -or $_.VMName -eq "MCF-OFC-TS1"}
Add-WBVirtualMachine -Policy $BackupPolicy -VirtualMachine $VM
$Disk = Get-WBDisk | Where-Object {$_.DiskNumber -eq 7}
$Target = New-WBBackupTarget -Disk $Disk -PreserveExistingBackups $true
Add-WBBackupTarget -policy $BackupPolicy -target $Target  -force
$sch2 = [datetime]"01/31/2011 21:00:00"
Set-WBSchedule -policy $BackupPolicy -schedule $sch2
Set-WBPolicy -Policy $BackupPolicy
Start-WBBackup -Policy $BackupPolicy
Remove-WBPolicy $BackupPolicy -Force