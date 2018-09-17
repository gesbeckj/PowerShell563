<#
.SYNOPSIS
This iterates through an Office 365 tenancy to identify possible unnecessary licenses. The first credential requires your normal password and you will go through an MFA prompt. The second credential requires an app pasword. 
.DESCRIPTION
This iterates through an Office 365 tenancy to identify possible unnecessary licenses. 
.EXAMPLE
DelegatedAdminLicenses.ps1 -FilePath "C:\users\owner\documents\Output.csv" -O365CredMFACred (Get-Credential) -O365Cred (Get-Credential)
.NOTES
You will need Delegated Admin Credentials. 
#>
param (
    #FilePathforExport
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$FilePath,

    #MFA365Cred
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [PSCredential]$O365CredMFACred,

    #AppPasswordCred
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [PSCredential]$O365Cred
    )




Write-Verbose "Connecting to Office 365"
Import-Module MSOnline
#$O365Cred = Get-Credential
Connect-MsolService –Credential $O365CredMFACred

    $outputData = @()
$Tenants = Get-MsolPartnerContract -All 
foreach ($tenant in $Tenants)
{


    $DomainName = $tenant.DefaultDomainName
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$DomainName" -Credential $O365Cred -Authentication Basic -AllowRedirection
    if ($Session -eq $null)
    {
        Write-Error "Office 365 Connection Failed" 
    }
    Import-PSSession $Session





    Write-Verbose "Getting mailbox information....this may take some time."
    $mailboxes = get-mailbox -ResultSize Unlimited | ?{$_.DisplayName -notlike "Discovery Search Mailbox"} 
    Write-Verbose "Mailbox information gathered"
    foreach($mailbox in $mailboxes)
    {
        Write-Verbose "Processing Mailbox $mailbox.userprincipalname"
        $licenseparts= (Get-MsolUser -UserPrincipalName $mailbox.userprincipalname -TenantId $tenant.TenantID).licenses.AccountSku.SkuPartNumber
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
            "O365_BUSINESS_ESSENTIALS" = "Office 365 Business Essentials"
            "POWER_BI_Standard" = "Power BI"
            "OFFICESUBSCRIPTION" = "Office Pro Plus"
            "PROJECTONLINE_PLAN_1" = "Project Plan 1"
            "MCOMEETADV" = "Audio Conferencing"
            "EXCHANGEARCHIVE_ADDON" = "Exchange Archive Add-on"
            "EMS" = "Enterprise Mobility & Scurity E3"
            "ATP_Enterprise" = "ATP"
            "INTUNE_A" = "InTune"
            "PROJECT_CLIENT_SUBSCRIPTION" = "Project Pro for Office 365"
            "VISIO_CLIENT_SUBSCRIPTION" = "Visio Pro for Office 365"
            "FLOW_FREE" = "Microsoft Flow"
            "ExchangeDeskLess" = "Exchange Kiosk"
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
        Write-Verbose "User license is $userlicense"

        $smtp = $mailbox.primarysmtpaddress 
        Write-Verbose "E-mail address detected as $smtp"
        $statistics = get-mailboxstatistics -identity "$smtp"
        $lastlogon = $statistics.lastlogontime 
        if($lastlogon -eq $null) { 
                $lastlogon = "Never Logged In" 
                Write-Verbose "User has never logged in"
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
        if ($data.Type -eq "SharedMailbox" -and ($data.License.Length -gt 2))
        {
            Write-Verbose "User account is shared mailbox with a license"
            $outputData += $data
        }
        if ($data.LastLogin -le (Get-Date).AddDays(-30) -and $data.Type -eq "UserMailbox")
        {
            Write-Verbose "User account has not been accessed in 30 days"
            $outputData += $data
        }
        Write-Verbose "Completed processing Mailbox $mailbox.userprincipalname"
    }

    Remove-PSSession $Session
    $outputData | Export-Csv -Path $FilePath
}
