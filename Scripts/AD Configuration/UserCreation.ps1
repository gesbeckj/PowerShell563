<#
.SYNOPSIS
This script creates users based on a CSV.
.DESCRIPTION
This script creates users based on a CSV. 
.EXAMPLE
UserCreation.ps1 -DomainName "Avengers.Com" -CompanyName "Avengers, LLC" -UPNDomain "@Avengers.com" -CSVName "C:\Shares.csv" 
.NOTES
Must run as Domain Admin. The UPN Domain must already be a valid UPN Suffix
#>

[CmdletBinding()]
param(
[string]$domainName,
[string]$CompanyName,
[string]$UPNDomain,
[string]$CSVName
)


    $splitDomain = $domainName.Split(".")
    $DCPath = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1] + ",DC=" + $splitDomain[2]
    $OUPath = "OU=" + $CompanyName + "," + $DCPath
    $UsersPath = "OU=Users," + $OUPath
    $userarray = import-csv $CSVName
    foreach($user in $userarray)
    {
    $firstname = $user.firstname
    $lastname = $user.lastname
    $password = $user.Password
    $username = $user.username
    $secPass = ConvertTo-SecureString -String $password -AsPlainText -Force
    $fullname = $firstname + " " + $lastname
    $Identity = "CN=" + $fullname + "," + $UsersPath
    $UPN = $username + "@" + $UPNDomain
    New-ADUser -Name $fullname -Path $UsersPath -SamAccountName $username -Type "User" -UserPrincipalName $UPN -DisplayName $fullname -Surname $lastname -GivenName $firstname
    Set-ADAccountPassword -Identity $Identity -NewPassword $secPass
    Enable-ADAccount -Identity $Identity
    #$O365UPN = $username + $$UPNDomain
    #Set-O365AssignedUser -LocalAccountName $username -O365AccountUPN $O365UPN
    Set-ADUser -ChangePasswordAtLogon:$false -Identity $Identity
    }