<#
.SYNOPSIS
This creates a reference image out of a base ISO and a Windows Cumulative Update. 
.DESCRIPTION
This creates a reference image out of a base ISO and a Windows Cumulative Update. It also install .Net 3.5
.EXAMPLE
BuildRefImage.ps1 -ISO "c:\users\james.gesbeck\Downloads\en_windows_server_2016_x64_dvd_9718492.iso" -MountFolder "C:\Mount" -RefImage "C:\Server2016.wim"
.NOTES
Must run as Local Administrator
#>
[CmdletBinding()]

param (
    #ISO file path
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ISO,

    #Cumulative Update File Path
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CU,

    #Mount Folder to Use
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$MountFolder,

    #Reference Image Output Location
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RefImage
)

# Verify that the ISO and CU files existnote
if (!(Test-Path -path $ISO)) {Write-Warning "Could not find Windows ISO file. Aborting..."; Break}
if (!(Test-Path -path $CU)) {Write-Warning "Could not find Cumulative Update for Windows. Aborting..."; Break}
 
# Mount the Windows ISO
Mount-DiskImage -ImagePath $ISO
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter + ":"

$DiskInfo = Get-WindowsImage -ImagePath "$ISODrive\Sources\install.wim"
$indexCount = $DiskInfo.Count
# Extract the Windows index to a new WIM
for ($index = 1; $index -le $indexCount; $index++ )
{
Export-WindowsImage -SourceImagePath "$ISODrive\Sources\install.wim" -SourceIndex $index -DestinationImagePath $RefImage
# Add the CU to the Windows Image
if (!(Test-Path -path $MountFolder)) {New-Item -path $MountFolder -ItemType Directory}
Mount-WindowsImage -ImagePath $RefImage -Index $index -Path $MountFolder
Add-WindowsPackage -PackagePath $CU -Path $MountFolder
# Add .NET Framework 3.5.1 to the Windows Server Image
Add-WindowsPackage -PackagePath $ISODrive\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab -Path $MountFolder
# Dismount the Windows Image
DisMount-WindowsImage -Path $MountFolder -Save
}
# Dismount the Windows ISO
Dismount-DiskImage -ImagePath $ISO

