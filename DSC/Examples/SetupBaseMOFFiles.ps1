$path = $pwd.ToString()
& 'C:\Users\james.gesbeck\Documents\GitHub\PowerShell563\DSC\Windows Server\BaseOSConfig.ps1' -Path $path
Rename-Item -Path ($path + '\localhost.mof') -NewName 'BaseOSConfig.mof'
New-DscChecksum -Path ($path + '\BaseOSConfig.mof')
& 'C:\Users\james.gesbeck\Documents\GitHub\PowerShell563\DSC\Windows Server\DSCEnableRDP.ps1' -path $path
Rename-Item -Path ($path + '\localhost.mof') -NewName 'EnableRDP.mof'
New-DscChecksum -Path ($path + '\EnableRDP.mof')