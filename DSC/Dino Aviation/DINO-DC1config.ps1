$domainAdmin = Get-Credential

$ConfigData= @{
    AllNodes = @(
            @{
                # The name of the node we are describing
               NodeName = "localhost"

                # The path to the .cer file containing the
                # public key of the Encryption Certificate
                # used to encrypt credentials for this node
                CertificateFile = "C:\Public Keys\DINO-DC1.cer"


                # The thumbprint of the Encryption Certificate
                # used to decrypt the credentials on target node
                Thumbprint = '‎CD82A4552B23B9946503C8AF071069D5B2D5C2F9'
                PSDSCAllowDomainUser = $true
            };
        );
    }

DINO-DC1 -DomainAdminCredential $domainAdmin -DomainName "ad.dinoaviation.tk" -InterfaceAlias "Ethernet" -IPv4Address "10.63.110.5/24" -DNSServers @("10.63.110.5","10.63.110.6") -Gateway "10.63.110.1" -ConfigurationData $ConfigData -StartRange "10.63.110.50" -EndRange "10.63.110.200"-DHCPNetworkID "10.63.110.0" -serverName "DINO-DC1"
