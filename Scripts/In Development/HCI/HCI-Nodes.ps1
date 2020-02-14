Add-Computer -DomainName HCI.local 

$nodes = "HCI-Host1","HCI-Host2"
foreach ($node in $nodes)
{
  icm $nodes {Install-WindowsFeature Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools} 
  icm $nodes {Install-WindowsFeature FS-FileServer}
  icm $nodes {Install-WindowsFeature Hyper-V -IncludeManagementTools}
  icm $nodes {Add-WindowsCapability -Online -Name ServerCore.AppCompatibility~~~~0.0.1.0}
}


$nodes = "HCI-Host1","HCI-Host2"
New-Cluster -Name cluster -Node $nodes -NoStorage -StaticAddress 192.168.170.235