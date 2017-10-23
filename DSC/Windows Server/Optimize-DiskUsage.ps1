Get-WindowsFeature | Where-Object {$_.Installed -match "False"} | Uninstall-WindowsFeature -Remove
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase