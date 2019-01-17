$BackupPolicy = New-WBPolicy
$VM = Get-WBVirtualMachine | Where-Object {$_.VMName -eq "MCF-OFC-Mitchell" -or $_.VMName -eq "MCF-OFC-TS1"}
Add-WBVirtualMachine -Policy $BackupPolicy -VirtualMachine $VM
$Disk = Get-WBDisk | Where-Object {$_.DiskNumber -eq 7}
$Target = New-WBBackupTarget -Disk $Disk
Add-WBBackupTarget -policy $BackupPolicy -target $Target -PreserveExistingBackups $true
$sch2 = [datetime]"01/31/2011 21:00:00"
Set-WBSchedule -policy $BackupPolicy -schedule $sch2
Start-WBBackup -Policy $BackupPolicy
Remove-WBBackup -Policy $BackupPolicy