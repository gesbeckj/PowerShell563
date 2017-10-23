$domainAdmin = Get-Credential

$ConfigData= @{ 
    AllNodes = @(     
            @{  
                # The name of the node we are describing 
               NodeName = "localhost" 

                # The path to the .cer file containing the 
                # public key of the Encryption Certificate 
                # used to encrypt credentials for this node 
                CertificateFile = "C:\PublicKeys\MDT-DC-01PublicKey.cer"


                # The thumbprint of the Encryption Certificate 
                # used to decrypt the credentials on target node 
                Thumbprint = '0C6AA07B2A60270DEEB59A9FB1111405794466D8'
                PSDSCAllowDomainUser = $true
            }; 
        );    
    }

    MDTDC01 -DomainAdminCredential $domainAdmin -DomainName "mdt.aberdean.local" -InterfaceAlias "Ethernet" -IPv4Address "192.168.170.6" -DNSServers @("192.168.170.5","192.168.170.6") -Gateway "192.168.170.1" -ConfigurationData $ConfigData -RDNSSubnets '192.168.170.0' -DHCPNetworkID '192.168.170.0' -StartRange '192.168.170.100' -EndRange '192.168.170.250' 