$users = get-msoluser -all | Where {$_.UserPrincipalName -ne "shuston@seventhwave.org"} | Where {$_.userPrincipalName -notlike "*EXT*"} |  Where {$_.UserPrincipalName -like "*@seventhwave901.onmicrosoft.com"}

foreach ($user in $users)
{
$Alias = $user.UserPrincipalName.Substring(0,$user.UserPrincipalName.IndexOf('@'))
Set-MsolUserPrincipalName -UserPrincipalName $user.userprincipalname -NewUserPrincipalName ($alias + '@seventhwave901.onmicrosoft.com')
}

$groups = Get-UnifiedGroup
foreach ($group in $groups)
{
$Alias = $group.PrimarySmtpAddress.Substring(0,$group.PrimarySmtpAddress.IndexOf('@'))
$group | Set-UnifiedGroup -PrimarySmtpAddress ($alias + '@seventhwave901.onmicrosoft.com')
}
