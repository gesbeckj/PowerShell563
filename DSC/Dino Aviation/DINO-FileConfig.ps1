#$domainAdmin = Get-Credential

$ConfigData= @{
    AllNodes = @(
            @{
                # The name of the node we are describing
               NodeName = "localhost"
                # The path to the .cer file containing the
                # public key of the Encryption Certificate
                # used to encrypt credentials for this node
                CertificateFile = "C:\Users\james.gesbeck\Documents\GitHub\PowerShell563\DSC\Dino Aviation\Keys\DINO-File1.cer"
                # The thumbprint of the Encryption Certificate
                # used to decrypt the credentials on target node
                Thumbprint = '7C3E0AD2ECA0206E574CDF4596018795EA88214F'
                PSDSCAllowDomainUser = $true
            };
        );
    }

Dino-File1 -DomainAdminCredential $domainAdmin -DomainName "ad.dinoaviation.tk" -InterfaceAlias "Ethernet" -IPv4Address "10.63.110.10/24" -DNSServers @("10.63.110.5","10.63.110.6") -Gateway "10.63.110.1" -serverName "DINO-File1" -ConfigurationData $ConfigData
$ConfigData= @{
    AllNodes = @(
            @{
                # The name of the node we are describing
               NodeName = "localhost"
                # The path to the .cer file containing the
                # public key of the Encryption Certificate
                # used to encrypt credentials for this node
                CertificateFile = "C:\Users\james.gesbeck\Documents\GitHub\PowerShell563\DSC\Dino Aviation\Keys\DINO-File2.cer"
                # The thumbprint of the Encryption Certificate
                # used to decrypt the credentials on target node
                Thumbprint = '‎6F87E5E9F717A54F38F38DE411D329B970D0627D'
                PSDSCAllowDomainUser = $true
            };
        );
    }

Dino-File2 -DomainAdminCredential $domainAdmin -DomainName "ad.dinoaviation.tk" -InterfaceAlias "Ethernet" -IPv4Address "10.63.110.11/24" -DNSServers @("10.63.110.5","10.63.110.6") -Gateway "10.63.110.1" -serverName "DINO-File2" -ConfigurationData $ConfigData