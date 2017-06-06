<#
.SYNOPSIS
This script finds any unused disks and configure an NTFS data volume. 
.DESCRIPTION
This script configures NTFS using GPT and names the filesystem "Data"
.EXAMPLE
FormatDisk.ps1
.NOTES
#>

Get-Disk |
Where partitionstyle -eq ‘raw’ |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel “Data” -Confirm:$false