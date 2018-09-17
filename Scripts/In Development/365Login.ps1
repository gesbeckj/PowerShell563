$outputData = @()
$mailboxes = get-mailbox -ResultSize Unlimited | ?{$_.DisplayName -notlike "Discovery Search Mailbox"} 
foreach($mailbox in $mailboxes)
{
    $licenseparts= (Get-MsolUser -UserPrincipalName $mailbox.userprincipalname).licenses.AccountSku.SkuPartNumber
    $Sku = @{ 
        "DESKLESSPACK" = "Office 365 (Plan K1)" 
        "DESKLESSWOFFPACK" = "Office 365 (Plan K2)" 
        "LITEPACK" = "Office 365 (Plan P1)" 
        "EXCHANGESTANDARD" = "Office 365 Exchange Online Only" 
        "STANDARDPACK" = "Office 365 (Plan E1)" 
        "STANDARDWOFFPACK" = "Office 365 (Plan E2)" 
        "ENTERPRISEPACK" = "Office 365 (Plan E3)" 
        "ENTERPRISEPACKLRG" = "Office 365 (Plan E3)" 
        "ENTERPRISEWITHSCAL" = "Office 365 (Plan E4)" 
        "STANDARDPACK_STUDENT" = "Office 365 (Plan A1) for Students" 
        "STANDARDWOFFPACKPACK_STUDENT" = "Office 365 (Plan A2) for Students" 
        "ENTERPRISEPACK_STUDENT" = "Office 365 (Plan A3) for Students" 
        "ENTERPRISEWITHSCAL_STUDENT" = "Office 365 (Plan A4) for Students" 
        "STANDARDPACK_FACULTY" = "Office 365 (Plan A1) for Faculty" 
        "STANDARDWOFFPACKPACK_FACULTY" = "Office 365 (Plan A2) for Faculty" 
        "ENTERPRISEPACK_FACULTY" = "Office 365 (Plan A3) for Faculty" 
        "ENTERPRISEWITHSCAL_FACULTY" = "Office 365 (Plan A4) for Faculty" 
        "ENTERPRISEPACK_B_PILOT" = "Office 365 (Enterprise Preview)" 
        "STANDARD_B_PILOT" = "Office 365 (Small Business Preview)" 
        "MIDSIZEPACK" = "Office 365 Trial" 
        "NonLicensed" = "User is Not Licensed" 
        "PROJECTPROFESSIONAL" = "Project Online Professional" 
        "DEFAULT_0" = "Unrecognized License" 
        "O365_BUSINESS_PREMIUM" = "Office 365 Business Premium"
        "VISIOCLIENT" = "Microsoft Visio"
        "RIGHTSMANAGEMENT" = "Azure AD Rights Management"
    } 
    $Tassignedlicense = ""
    $Fassignedlicense = ""
    $assignedlicense = ""
    $userlicense = ""
    foreach($license in $licenseparts) { 
        if($Sku.Item($license)) { 
            $Tassignedlicense = $Sku.Item("$($license)") + "::" + $Tassignedlicense 
        } 
        else { 
            Write-Warning -Message "user $($user) has an unrecognized license $license. Please update script." 
            $Fassignedlicense = $Sku.Item("DEFAULT_0") + "::" + $Fassignedlicense 
        } 
        $assignedlicense = $Tassignedlicense + $Fassignedlicense 
         
    } 
    $userLicense = $assignedlicense



    $smtp = $mailbox.primarysmtpaddress 
    $statistics = get-mailboxstatistics -identity "$smtp"
    $lastlogon = $statistics.lastlogontime 
    if($lastlogon -eq $null) { 
            $lastlogon = "Never Logged In" 
    }
    $upn = $mailbox.userprincipalname 
    $whencreated = $mailbox.whenmailboxcreated 
    $type = $mailbox.recipienttypedetails
    $DisplayName = (Get-User $upn).DisplayName 
    $data = New-Object PSObject -Property @{
        UPN = $UPN
        SMTP = $SMTP
        Created = $whencreated
        Type = $type
        LastLogin = $lastlogon
        License = $userLicense
        }
    $outputData += $data

}