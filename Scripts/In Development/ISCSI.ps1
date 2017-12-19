Set-Service –Name MSiSCSI –StartupType Automatic
Start-Service MSiSCSI
New-IscsiTargetPortal -TargetPortalAddress 10.20.15.9
$target = Get-IscsiTarget
Connect-IscsiTarget -NodeAddress $target.NodeAddress
Get-IscsiConnection
Get-IscsiSession | Register-IscsiSession

Get-Disk -Number 3 | Where-Object BusType –eq “iSCSI” | Where-Object OperationalStatus -eq "Offline" | Initialize-Disk  –PartitionStyle GPT –PassThru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume