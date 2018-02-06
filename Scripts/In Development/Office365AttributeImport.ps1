$file = "C:\Users\Avocadowin\desktop\sw.xml"
$userlist = Import-Clixml $file
foreach ($user in $userlist)
{
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$uid = $user.Identity
#$uid = read-host "Please enter User's username"
Set-ADUser $uid -Clear homemdb, homemta, msExchHomeServerName, msExchPoliciesExcluded
Set-ADUser $uid -Replace @{msExchRemoteRecipientType="3"}
Set-ADUser $uid -Replace @{mailNickname="$uid"}
Set-ADUser $uid -Replace @{msExchProvisioningFlags="0"}
Set-ADUser $uid -Replace @{msExchModerationFlags="6"}
Set-ADUser $uid -Replace @{msExchAddressBookFlags="1"}
Set-ADUser $uid -Replace @{msExchRecipientDisplayType="-2147483642"}
Set-ADUser $uid -Replace @{msExchRecipientTypeDetails="2147483648"}
Set-ADUser $uid -Replace @{msExchRecipientTypeDetails="2147483648"}
$description = (get-aduser $uid -Properties Description).Description
Set-AdUser $uid -Replace @{Title=$description}
foreach ($emailAddr in $user.EmailAddresses)
{
    Write-Host $emailAddr
    Set-AdUser $uid -Add @{proxyAddresses=$emailAddr}
}
Set-AdUser $uid -Replace @{mail=$user.PrimarySmtpAddress.ToString()}
Set-RemoteMailbox $uid -PrimarySMTPAddress $user.PrimarySmtpAddress.ToString()  -RemoteRoutingAddress $user.PrimarySmtpAddress.ToString() 
}
get-mailbox * | where {$_.IsMailboxEnabled -eq $true} | Where  {$_.RecipientType -eq "UserMailbox"} | Where {$_.RecipientTypeDetails -eq "UserMailbox"} |  select * | select Identity, primarySmtpAddress, EmailAddresses | export-clixml -path C:\users\james.gesbeck\Desktop\sw.xml