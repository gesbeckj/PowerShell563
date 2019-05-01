$file = "C:\Users\Administrator\desktop\sw.xml"
$userlist = Import-Clixml $file
foreach ($user in $userlist)
{
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$uid = $user.Identity
$pmail = $uid+"@seventhwave.org"
Set-ADUser $uid -Clear homemdb, homemta, msExchHomeServerName, msExchPoliciesExcluded
Set-ADUser $uid -Add @{msExchRemoteRecipientType="4"}
Set-ADUser $uid -Add @{mailNickname="$uid"}
Set-ADUser $uid -Add @{msExchProvisioningFlags="0"}
Set-ADUser $uid -Add @{msExchModerationFlags="6"}
Set-ADUser $uid -Add @{msExchAddressBookFlags="1"}
Set-ADUser $uid -Replace @{targetaddress="$pmail"}
Set-ADUser $uid -Replace @{msExchRecipientDisplayType="-2147483642"}
Set-ADUser $uid -Replace @{msExchRecipientTypeDetails="2147483648"}
Set-ADUser $uid -Replace @{msExchRecipientTypeDetails="2147483648"}
foreach ($emailAddr in $user.proxyAddresses)
{
    Set-AdUser $uid -Add @{proxyAddresses=$emailAddr}
}
Set-AdUser $uid -Replace @{mail=$user.PrimarySmtpAddress.ToString()}
}