$Tenants = Get-MsolPartnerContract -All 
$role = Get-MsolRole -RoleName "Company Administrator"
$AdminInfo = Get-MsolRoleMember -RoleObjectId $role.ObjectId |  Select DisplayName, EmailAddress, isLicensed
$adminInfo = @()
foreach ($company in $Tenants)
{
    
   # write-host $company
   $Admins = Get-MsolRoleMember -RoleObjectId $role.ObjectId -TenantId $company.TenantId   | Where-Object {$_.isLicensed -eq $true} | Select DisplayName, EmailAddress
   foreach ($admin in $admins)
   {
    $data = New-Object PSObject -Property @{
        Tenant = $company.name
        DisplayName = $admin.DisplayName
        EmailAddress = $admin.EmailAddress
    }
    $AdminInfo += $data
   }

}