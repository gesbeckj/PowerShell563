$domainAdmin = Get-Credential

$ConfigData= @{
    AllNodes = @(
            @{
                # The name of the node we are describing
               NodeName = "localhost"

                # The path to the .cer file containing the
                # public key of the Encryption Certificate
                # used to encrypt credentials for this node
                CertificateFile = "C:\Public Keys\DINO-Sync.cer"


                # The thumbprint of the Encryption Certificate
                # used to decrypt the credentials on target node
                Thumbprint = '‎‎F931BAC3A8F6909CC79FD25565E609A469C7393B'
                PSDSCAllowDomainUser = $true
            };
        );
    }

DINO-Sync -DomainAdminCredential $domainAdmin -DomainName "ad.dinoaviation.tk" -InterfaceAlias "Ethernet" -serverName "DINO-Sync" -ConfigurationData $ConfigData
