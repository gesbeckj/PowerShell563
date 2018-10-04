#Enable RDP
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" 

#Download but do not install updates
set-itemproperty –Path ‘HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU’ –name “AUOptions” –Value 3

#Disable Windows Error Reporting
Disable-WindowsErrorReporting

#Disable Customer Improvement Program
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0

#Enable Windows File Sharing
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.100.63.31 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("10.100.63.5", "10.63.100.63.6")
Get-NetAdapter | New-NetRoute -DestinationPrefix "0.0.0.0/0" -NextHop 10.100.63.1

Add-Computer -DomainName "ad.goblinsolutions.tk" -Credential (Get-Credential) -NewName "GS-WSUS"

Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
New-Item -Path C: -Name WSUS -ItemType Directory
& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=C:\WSUS

$wsus = Get-WSUSServer
Write-Verbose "Connect to WSUS server configuration" -Verbose
$wsusConfig = $wsus.GetConfiguration()
Write-Verbose "Set to download updates from Microsoft Updates" -Verbose
 
Set-WsusServerSynchronization -SyncFromMU
 
Write-Verbose "Set Update Languages to English and save configuration settings" -Verbose
 
$wsusConfig.AllUpdateLanguagesEnabled = $false           
$wsusConfig.SetEnabledUpdateLanguages("en")           
$wsusConfig.Save()
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
 
While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 5
}
 
Write-Verbose "Sync is done" -Verbose


Get-WsusProduct | Set-WsusProduct -Disable
Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Windows Server 2019" } | Set-WsusProduct
Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match  "Windows 10" } | Set-WsusProduct

Get-WsusClassification | Where-Object {
    $_.Classification.Title -in (
    'Critical Updates',
    'Definition Updates',
    'Security Updates',
    'Service Packs',
    'Update Rollups',
    'Updates',
    'Upgrades')
} | Set-WsusClassification

$subscription.SynchronizeAutomatically=$true
 
# Set synchronization scheduled for midnight each night
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay=1
$subscription.Save()
 
# Kick off a synchronization
$subscription.StartSynchronization()
write-host 'Starting WSUS Sync, will take some time' -ForegroundColor Magenta
Start-Sleep -Seconds 60 # Wait for sync to start before monitoring
while ($subscription.GetSynchronizationProgress().ProcessedItems -ne $subscription.GetSynchronizationProgress().TotalItems) {
    Write-Progress -PercentComplete (
    $subscription.GetSynchronizationProgress().ProcessedItems*100/($subscription.GetSynchronizationProgress().TotalItems)
    ) -Activity "WSUS Sync Progress"
}
Write-Host "Sync is done." -ForegroundColor Green
$rule = $wsus.GetInstallApprovalRules()
$rule.Item(0).enabled = $True