Get-WindowsFeature *RSAT-Cluster* | Add-WindowsFeature
Get-WindowsFeature *Hyper-V-* | Add-WindowsFeature
New-Cluster "Cluster" -Node "Host1"
Get-ClusterAvailableDisk | Add-ClusterDisk
Set-ClusterQuorum -DiskWitness "Cluster Disk #"
Add-ClusterSharedVolume - "Cluster Disk #"


$Disks = Get-CimInstance -Namespace Root\MSCluster -ClassName MSCluster_Resource | ?{$_.Type -eq 'Physical Disk'}
$Disks | %{Get-CimAssociatedInstance -InputObject $_ -ResultClassName MSCluster_DiskPartition}
