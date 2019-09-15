$file = "C:\sw.xml"
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


foreach ($emailAddr in $user.EmailAddresses)
{
    Write-Host $emailAddr
    Set-AdUser $uid -Add @{proxyAddresses=$emailAddr}
}
Set-AdUser $uid -Replace @{mail=$user.PrimarySmtpAddress.ToString()}
Set-RemoteMailbox $uid -PrimarySMTPAddress $user.PrimarySmtpAddress.ToString()  -RemoteRoutingAddress $user.PrimarySmtpAddress.ToString() 
}



get-mailbox * | where {$_.PrimarySmtpAddress -like '*@weccusa.org' -or $_.PrimarySmtpAddress -like '*@energyfinancesolutions.com' -or $_.PrimarySmtpAddress -like '*@michigan-energy.org' -or $_.PrimarySmtpAddress -like '*@pacewi.org'} |  where {$_.IsMailboxEnabled -eq $true} | Where  {$_.RecipientType -eq "UserMailbox"} | Where {$_.RecipientTypeDetails -eq "UserMailbox"} |  select * | select Alias, Identity, primarySmtpAddress, EmailAddresses | export-clixml C:\users\james.gesbeck\Desktop\sw.xml


$ImmutableID = 'BZsdrJPZAEGS1ca7wQ6U8w=='
Set-MSOLuser -UserPrincipalName mpolselli@weccusa.org -ImmutableId $ImmutableID

$userlist = import-csv C:\temp\Imm.csv
foreach($user in $userlist)
{
    Set-MSOLuser -UserPrincipalName ($user.username + '@weccusa.org') -ImmutableId $user.ImmutableID
}