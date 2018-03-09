$Tenants = Get-MsolPartnerContract -All | Select-Object TenantId
$role = Get-MsolRole -RoleName "Company Administrator"
$AdminInfo = Get-MsolRoleMember -RoleObjectId $role.ObjectId | Where-Object {$_.DisplayName -ne "Abe Aberdean"} | Where-Object {$_.EmailAddress -notlike "administrator@*"} |  Select DisplayName, EmailAddress
foreach ($company in $Tenants)
{
    
   # write-host $company
    $AdminInfo += Get-MsolRoleMember -RoleObjectId $role.ObjectId -TenantId $company.TenantId | Where-Object {$_.DisplayName -ne "Abe Aberdean"} | Where-Object {$_.EmailAddress -notlike "administrator@*"} | Where-Object {$_.EmailAddress -notlike "admin@*"} | Select DisplayName, EmailAddress
}