
Import-Module MSOnline
$O365Cred = Get-Credential
Connect-MsolService –Credential $O365Cred
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

$O365Cred = Get-Credential
Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $O365Cred
Import-PSSession $sfboSession

