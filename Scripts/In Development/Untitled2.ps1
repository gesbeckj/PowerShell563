Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$username = read-host "Please enter User's username"
$uid = $username + "@gesbeck.org"
Set-ADUser $uid -Clear homemdb, homemta, msExchHomeServerName, msExchPoliciesExcluded
Set-ADUser $uid -Add @{msExchRemoteRecipientType="6"}
Set-ADUser $uid -Add @{mailNickname="$uid"}
Set-ADUser $uid -Add @{msExchProvisioningFlags="0"}
Set-ADUser $uid -Add @{msExchModerationFlags="6"}
Set-ADUser $uid -Add @{msExchAddressBookFlags="1"}
Set-ADUser $uid -Replace @{msExchRecipientDisplayType="-2147483642"}
Set-ADUser $uid -Replace @{msExchRecipientTypeDetails="2147483648"}
