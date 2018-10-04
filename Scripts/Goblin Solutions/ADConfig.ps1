$CompanyName = "Goblin Solutions"
$domainName = "ad.goblinsolutions.tk"
$splitDomain = $domainName.Split(".")
$DCPath = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
New-ADOrganizationalUnit -Name $CompanyName -ProtectedFromAccidentalDeletion $true -Path $DCPath
$OUPath = "OU=" + $CompanyName + "," + $DCPath
New-ADOrganizationalUnit -Name "Security Groups" -ProtectedFromAccidentalDeletion $true -path $OUPath
New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $true -path $OUPath
New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $true -path $OUPath
New-ADOrganizationalUnit -Name "Servers" -ProtectedFromAccidentalDeletion $true -path $OUPath
$Identity = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration," + $DCPath
Enable-ADOptionalFeature –Identity $Identity –Scope ForestOrConfigurationSet –Target $domainName -Confirm:$false