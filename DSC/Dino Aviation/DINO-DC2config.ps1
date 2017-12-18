$domainAdmin = Get-Credential

$ConfigData= @{
    AllNodes = @(
            @{
                # The name of the node we are describing
               NodeName = "localhost"

                # The path to the .cer file containing the
                # public key of the Encryption Certificate
                # used to encrypt credentials for this node
                CertificateFile = "C:\Public Keys\DINO-DC2.cer"


                # The thumbprint of the Encryption Certificate
                # used to decrypt the credentials on target node
                Thumbprint = '‎‎0b01812952665674b12f0bc9e8c9e62f6c87bf9a'
                PSDSCAllowDomainUser = $true
            };
        );
    }

DINO-DC2 -DomainAdminCredential $domainAdmin -DomainName "ad.dinoaviation.tk" -InterfaceAlias "Ethernet" -IPv4Address "10.63.110.5/24" -DNSServers @("10.63.110.5","10.63.110.6") -Gateway "10.63.110.1" -ConfigurationData $ConfigData  -serverName "DINO-DC2"
