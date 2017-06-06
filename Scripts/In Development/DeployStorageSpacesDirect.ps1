$nodes = "node1", "node2", "node3"
foreach ($node in $nodes)
{
  icm $nodes {Install-WindowsFeature Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools} 
  icm $nodes {Install-WindowsFeature FS-FileServer}
}
New-Cluster -Name cluster -Node $nodes –NoStorage –StaticAddress 10.0.0.10
enter-pssession -ComputerName node1
Set-ClusterQuorum -CloudWitness -AccountName storagespacesdirect960 -AccessKey Up9cg9od0GztpGr0ly98P/8mUuOzEX1SE5Y9BGLDID+HHCbKrci0fmkoE1XHf4ADETnE136bzkTDIXj9PqUiAg==
Enable-CLusterS2D
new-volume -StoragePoolFriendlyName S2D* -FriendlyName VDisk -FileSystem CSVFS_REFS -Size 3000GB