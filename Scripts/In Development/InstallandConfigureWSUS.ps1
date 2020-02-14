Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
New-Item -Path D: -Name WSUS -ItemType Directory
& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=D:\WSUS

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
Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Windows 7" } | Set-WsusProduct
Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -in "Windows 10" } | Set-WsusProduct

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