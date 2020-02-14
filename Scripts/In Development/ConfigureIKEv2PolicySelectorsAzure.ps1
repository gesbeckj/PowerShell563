Connect-AzAccount
Get-AzSubscription | Select-AzSubscription
$IpsecPolicy = New-AzIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA1 -DhGroup DHGroup2 -IpsecEncryption AES256 -IpsecIntegrity SHA1 -PfsGroup None -SALifeTimeSeconds 3600
$VPNconnection = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName ASR -Name VPN_Connection-BCN
Set-AzVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $VPNconnection -IpsecPolicies $IpsecPolicy -UsePolicyBasedTrafficSelectors $true