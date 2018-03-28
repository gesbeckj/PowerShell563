$url = "https://go.microsoft.com/fwlink/p/?linkid=859206"
if (!(Test-Path -path "C:\Temp")) {New-Item -path "C:\Temp" -ItemType Directory}
$output = "C:\Temp\ADKsetup.exe"
Invoke-WebRequest -uri $url -OutFile $output
$cmd = "C:\Temp\adksetup.exe"
$args = '/quiet /installpath "D:\Program Files (x86)\Windows Kits\10" /features OptionId.DeploymentTools OptionID.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool /ceip off'
Start-Process -FilePath $cmd -ArgumentList $args -Wait
Get-WindowsFeature *WDS* | Add-WindowsFeature
New-Item -path "D:\RemoteInstall" -ItemType Directory
Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
    -ArgumentList "/Initialize-Server", "/REMINST:D:\RemoteInstall"
Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
    -ArgumentList "/Set-Server", "/UseDhcpPorts:Yes", "/DhcpOption60:No"
Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
    -ArgumentList "/Set-Server", "/Authorize:Yes"
Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
    -ArgumentList "/Set-Server", "/AnswerClients:All"
Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
    -ArgumentList "/Set-Server", "/PxePromptPolicy", "/Known:NoPrompt", "/New:NoPrompt"
$url = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
if (!(Test-Path -path "C:\Temp")) {New-Item -path "C:\Temp" -ItemType Directory}
$output = "C:\Temp\MicrosoftDeploymentToolkit_x64.msi"
Invoke-WebRequest -uri $url -OutFile $output
$cmd = "msiexec.exe"
$args = '/i "C:\Temp\MicrosoftDeploymentToolkit_x64.mxi" TARGETDIR="D:\Program Files\Microsoft Deployment Toolkit" INSTALLDIR="D:\Program Files\Microsoft Deployment Toolkit"'
Start-Process -FilePath $cmd -ArgumentList $args -Wait
