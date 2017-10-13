$wimlocation = "D:\MDTCache"
$files = Get-ChildItem -Path $wimlocation | Where-Object {! $_.PSIsContainer} | Where-Object {$_.Extension -eq '.wim'} | select-object FullName
foreach ($file in $files)
{
$imageName = Get-WindowsImage -ImagePath $file.FullName -Index 1 | select-object ImageName
$build = Get-WindowsImage -ImagePath $file.FullName -Index 1 | Select-Object Build
New-Item -Path "DS001:\Operating Systems" -Name ($Imagename.ImageName) -ItemType "folder"
New-Item -Path "DS001:\Operating Systems" -Name ($Imagename.ImageName + "\Build " + $build.build) -ItemType "folder"
Import-MDTOperatingSystem -Path ("DS001:\Operating Systems\"+ $imageName.ImageName + "\Build " + $build.build) -DestinationFolder ($ImageName.ImageName + " " + $build.Build) –SourceFile $file.FullName
}