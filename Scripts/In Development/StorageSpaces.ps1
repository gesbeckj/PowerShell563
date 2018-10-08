New-StoragePool –PhysicalDisk (Get-PhysicalDisk –CanPool $True) –FriendlyName “Storage" -StorageSubSystemFriendlyName "Windows Storage*"

New-StorageTier -StoragePoolFriendlyName "Storage" -FriendlyName "Storage_HDD_Tier" -MediaType HDD

New-StorageTier -StoragePoolFriendlyName "Storage" -FriendlyName "Storage_SSD_Tier" -MediaType SSD

$SSD = Get-StorageTier -FriendlyName *SSD*
$HDD = Get-StorageTier -FriendlyName *HDD*

$SSDMaxSize = (Get-StorageTierSupportedSize "Storage_SSD_Tier" -ResiliencySettingName mirror).TierSizeMax
$HDDMaxSize = (Get-StorageTierSupportedSize "Storage_HDD_Tier" -ResiliencySettingName mirror).TierSizeMax
Get-StoragePool "Storage" | New-VirtualDisk -FriendlyName "Storage" -ResiliencySettingName "Mirror" -StorageTiers $SSD, $HDD -StorageTierSizes ($SSDMaxSize -11GB ), ($HDDMaxSize - 5GB) -WriteCacheSize 10GB

Get-VirtualDisk Storage | Get-Disk | Set-Disk -IsReadOnly 0
Get-VirtualDisk Storage | Get-Disk | Set-Disk -IsOffline 0
Get-VirtualDisk Storage | Get-Disk | Initialize-Disk -PartitionStyle GPT
Get-VirtualDisk Storage | Get-Disk | New-Partition -DriveLetter “D” -UseMaximumSize
Initialize-Volume -DriveLetter “D” -FileSystem NTFS -Confirm:$false