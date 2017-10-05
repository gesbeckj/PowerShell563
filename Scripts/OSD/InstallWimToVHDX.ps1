$VHDXFile = "C:\Test.vhdx"
$SourceFile = "C:\Server2016.wim"
$Index = 4


New-VHD -Path $VHDXFile -Dynamic -SizeBytes $VHDSize -Verbose
Mount-DiskImage -ImagePath $VHDXFile -Verbose
$VHDXDisk = Get-DiskImage -ImagePath $VHDXFile | Get-Disk -Verbose
$VHDXDiskNumber = [string]$VHDXDisk.Number

Initialize-Disk -Number $VHDXDiskNumber -PartitionStyle GPT -Verbose
$VHDXDrive1 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size 499MB -Verbose 
$VHDXDrive1 | Format-Volume -FileSystem FAT32 -NewFileSystemLabel System -Confirm:$false -Verbose
$VHDXDrive2 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size 128MB
$VHDXDrive3 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize -Verbose
$VHDXDrive3 | Format-Volume -FileSystem NTFS -NewFileSystemLabel OSDisk -Confirm:$false -Verbose
Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber -AssignDriveLetter
$VHDXDrive1 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber
Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber -AssignDriveLetter
$VHDXDrive3 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber
$VHDXVolume1 = [string]$VHDXDrive1.DriveLetter+":"
$VHDXVolume3 = [string]$VHDXDrive3.DriveLetter+":"
Expand-WindowsImage -ImagePath $SourceFile -Index $Index -ApplyPath $VHDXVolume3\ -Verbose -ErrorAction Stop
cmd /c "$VHDXVolume3\Windows\system32\bcdboot $VHDXVolume3\Windows /s $VHDXVolume1 /f ALL"
$DiskPartTextFile = New-Item "diskpart.txt" -type File -Verbose -Force
Set-Content $DiskPartTextFile "select disk $VHDXDiskNumber" -Verbose
Add-Content $DiskPartTextFile "Select Partition 2" -Verbose
Add-Content $DiskPartTextFile "Set ID=c12a7328-f81f-11d2-ba4b-00a0c93ec93b OVERRIDE" -Verbose
Add-Content $DiskPartTextFile "GPT Attributes=0x8000000000000000" -Verbose
$DiskPartTextFile
cmd /c "diskpart.exe /s .\diskpart.txt"
Dismount-DiskImage -ImagePath $VHDXFile -Verbose
