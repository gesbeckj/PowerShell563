# Critical Process

## Automation

- Office 365 PowerShell allows us to run commands against and makes changes to all of our clients en masse. As an example, we can export out a list of every single login across all of our clients from a non-US country by running a single script. We can also disable IMAP on all newly created accounts globally in a similiar manner. https://gcits.com/knowledge-base/disable-pop-imap-mailboxes-office-365/ https://gcits.com/knowledge-base/export-list-locations-office-365-users-logging/ (Sample Script on Disk)
- Meraki MDM provides an API with similiar capabilities to the Office 365 PowerShell. The newer SEP Cloud provides similiar API capabilities. This would allow things such as automated alerts/checks for workstations not checking in or automated alerts when counts do not correctly match. https://documentation.meraki.com/zGeneral_Administration/Other_Topics/The_Cisco_Meraki_Dashboard_API https://apidocs.symantec.com/home/SEPC
- Our servers are cattles, not pets. Right servers are managed individually on a case by case basis instead of like cattle which are managed as a group. https://msdn.microsoft.com/en-us/magazine/mt826329.aspx. 
- We could manage this centrally via Update Management in Azure. Does not need to be everything, but could start with using as a central reporting console. https://docs.microsoft.com/en-us/azure/automation/automation-update-management (Goblin Solution Demo Available)
- Server deployments are currently done manually based on an incomplete and rarely update standard. For example, SSL 3.0 was manually disabled (see #16767/#16768) yet this was never added to standard and has not been done on newly deployed 2012 R2 systems. An automated script as part of the server deployment process (either run via MDT or manually) would allow smaller changes like this to be performed consistently on all systems. https://support.microsoft.com/en-us/help/3009008/microsoft-security-advisory-vulnerability-in-ssl-3-0-could-allow-infor
- We do not have a time efficient way to implement critical security changes and as a result we have not performed them. Microsoft advise on SMBv1 is "Stop using SMB1. Stop using SMB1. STOP USING SMB1!" SMBv1 is the attack vector used by WannaCry and its decendants. This can be done on servers with one line of code (Remove-WindowsFeature FS-SMB1 or 	Set-SmbServerConfiguration -EnableSMB1Protocol $false or Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 –Force) https://blogs.technet.microsoft.com/filecab/2016/09/16/stop-using-smb1/
)
# Office 365

## Azure AD

- Conditional Access would allow less impactful MFA by only requiring it for specific logins versus always require. 
- Reports are available for numerous aspects of risky logins including by location, by failure count, etc. Even though we may not be able to increase the secure score by manually reviewing them, we should automate a scan of them. 
- We have numerous PowerBI and GraphAPI reports and data available. We should take advantage of this. This includes https://github.com/Microsoft/Partner-Smart-Office

## Exchange Online

- IMAP/POP are insecure legacy protocols and should be disabled by default. 
- We should implement a base level ActiveSync policy. This increases secure score and increases security for minimal effort. This is also something that can be scripted across multiple tenants. 
- DKIM records. 

## OneDrive

- We have no security for OneDrive. Microsoft has security tools that can do things such as detect active Crypto attacks on the files themselves. Although we have done an amazing job of limiting Crypto attacks via our SSM deployments, defense in depth should be practiced. 

# Workstations

## BitLocker

- BitLocker should be our default. MDT may actually be enabling it by default. 

## Local Admin Password

- Every single workstation at every single client has the same default administrator password. Making this worse, all of our workstations allow network access via the default administrator account. This is also exploitable via Pass the Hash attacks as the Hash for the local administrator is identical. Even wrose numerous clients know our default password. 
- All systems should have different local administrator passwords. https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/attractive-accounts-for-credential-theft
- How are we going to justify this to our clients when we get asked about it? or if one of our competitors finds out and brings it up during an audit? 
- Microsoft has a solution specifically for this. https://technet.microsoft.com/en-us/mt227395.aspx

## General Security Posture

- We do not follow Microsoft best practice on CRITICAL items including SMBv1 being enabled and SSLv3 being enabled. These are vectors that are being actively exploited in the wild. 

## GPO Restrictions

- We do not follow Microsoft's best practices for workstation security. Microsoft even provides a GPO that implements all of their best pratcies yet we do not use it. https://blogs.technet.microsoft.com/secguide/2017/10/18/security-baseline-for-windows-10-fall-creators-update-v1709-final/

# Servers

## Update Management

- We could manage this centrally via Update Management in Azure. Does not need to be everything, but could start with using as a central reporting console. https://docs.microsoft.com/en-us/azure/automation/automation-update-management (Goblin Solution Demo Available)

## Standard Security Posture

- We do not follow Microsoft best practice on CRITICAL items including SMBv1 being enabled and SSLv3 being enabled. These are vectors that are being actively exploited in the wild. 
- "Domain controllers should not run any software that is not required for the domain controller to function or doesn't protect the domain controller against attacks." https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/avenues-to-compromise
- We meet less than 60 % of Microsoft's security reccomendations. See Azure Security Baseline via Goblin Solutions Demo. 

## Local Admin Password

- Local administrator account credentials are not universally documents for servers. Sometimes they are set to the domain administrator password and other times they are the Aberdean default password. This is terrible. https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/attractive-accounts-for-credential-theft

## GPO Restrictions

- Microsoft provides a security baseline as a GPO that can be easily deployed in masse. This would ensure that systems are following Microsoft's best practice for security with minimal effort. https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines
- https://aka.ms/2016secbaseline

## Use of Internet
- "Domain controllers should not run any software that is not required for the domain controller to function or doesn't protect the domain controller against attacks." https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/avenues-to-compromise
- Eventually we are going to get burned. All it would take is a malicious advertisement that appears while running a speed test. 
- https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/attractive-accounts-for-credential-theft
- "One of the checks that is performed as part of an Active Directory Security Assessment is the use and configuration of Internet Explorer on domain controllers. Internet Explorer (or any other web browser) should not be used on domain controllers, but analysis of thousands of domain controllers has revealed numerous cases in which privileged users used Internet Explorer to browse the organization's intranet or the Internet."

# Firewall

## Outbound Rules

- This was something that was more a focus previously due to client workstations sending spam. We should change to a default policy of blocking outbound traffic that should not be originating from client workstations. This includes SMB and SMTP. 

## Geographic Restrictions

- We should test and impelement a policy of blocking traffic to certain countries. This could be either a whitelist policy where we only allow certain countries or a blacklist where we only block higher risk countries. This must be carefully tested as some of our vendors are based in higher risk countries and blocking those countries breaks critical functionality. E.g. Synology. 

# Network

## DHCP Security

- All of our modern switches support DHCP sniffing, dynamic ARP inspection and strom control. While we have yet to be impacted by a network based attack, all it would take is a user plugging a Best Buy special router into their desk port and they could bring down the network. 

## Management VLANs

- iLO / DRAC / VCenter / RDP / etc. should NOT be accessible to client workstations. These should be on a restricted VLAN. This not only improves actual security, but will also improve security audit reports generated for our clients. 

# PKI

## Self-Signed Certificates

- We need to stop relying on self signed certificates. We should NEVER tell a client to ignore a security warning. Microsoft guidance is that self signed certificates should not be deployed to production environment yet we do it all the time. https://blogs.msdn.microsoft.com/shreyasgowda/2017/08/18/public-certificates-vs-private-certificates-vs-self-signed-certificates/
- All of our Essential Servers have a CA built-in. We have a CA SOP due to the need for domain controllers having signed certificates for Windows Hello for Business. It is trivial to implement and avoids an easy flag for any security auditor. It also provides something we can point to during any audit that our competitors are doing. 

# Security Audit

- While expensive, we should consider building a "typical" client deployment and having a security audit performed on it. This would allow us to more generally assess our security posture for our clients without needing to audit all of them. It will help us provide a secure environment as we are not security experts and are currently failing to meet best practices. 

# Security Reccomendation Presentation

- We should generate a template for our security reccomendations and walk clients through it line by line and have them select what they want. They can then sign it at the bottom. Not only does it provide a uniform way for us to approach security to all of our clients, it also let us document their refusal implement security practices that could come back to bite them in the a$$.
- We need to continue to work to refine how to message to clients things that they need to do because it is good for them even if they might not want to. We have had this happen with the Trend to Symantec migration, with MFA implementation and this is bound to occur in the future. 