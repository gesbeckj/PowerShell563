$nodes = "vmhost5", "vmhost9"
foreach ($node in $nodes)
{
  icm $nodes {Install-WindowsFeature Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools} 
  icm $nodes {Install-WindowsFeature FS-FileServer}
}
$nodes = "vmhost5", "vmhost9"
New-Cluster -Name cluster -Node $nodes -NoStorage -StaticAddress 192.168.170.235
enter-pssession -ComputerName node1
Set-ClusterQuorum -CloudWitness -AccountName storagespacesdirect960 -AccessKey Up9cg9od0GztpGr0ly98P/8mUuOzEX1SE5Y9BGLDID+HHCbKrci0fmkoE1XHf4ADETnE136bzkTDIXj9PqUiAg==
Enable-CLusterS2D
new-volume -StoragePoolFriendlyName S2D* -FriendlyName VDisk -FileSystem CSVFS_REFS -Size 3000GB


.\create-vmfleet.ps1 -BaseVHD C:\ClusterStorage\collect\Golden.vhdx -vms 10 -AdminPass Gesbeck1 -ConnectPass Gesbeck1 -ConnectUser administrator
.\set-vmfleet.ps1 -ProcessorCount 4 -MemoryStartupBytes 1024MB -DynamicMemory:$true -MemoryMinimumBytes 1024MB -MemoryMaximumBytes 32GB
.\start-vmfleet.ps1
.\watch-cluster.ps1
.\start-sweep.ps1 -b4K -d600 -o4 -w25 -L -Z1G