$file = "C:\Users\Administrator\desktop\sw.xml"
$userlist = Import-Clixml $file
foreach ($user in $userlist)
{
$uid = $user.Identity
foreach ($emailAddr in $user.proxyAddresses)
{
    Set-AdUser $uid -Add @{proxyAddresses=$emailAddr}
}
}