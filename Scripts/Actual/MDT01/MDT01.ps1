Get-Disk |
Where-Object partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false

