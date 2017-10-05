$domainAdmin = Get-Credential

$ConfigData= @{ 
    AllNodes = @(     
            @{  
                # The name of the node we are describing 
               NodeName = "localhost" 

                # The path to the .cer file containing the 
                # public key of the Encryption Certificate 
                # used to encrypt credentials for this node 
                CertificateFile = "C:\PublicKeys\MDTServerDscPublicKey.cer" 


                # The thumbprint of the Encryption Certificate 
                # used to decrypt the credentials on target node 
                Thumbprint = 'F7F03D17AF2FA167200D84CB78487B2E8835F698'
                PSDSCAllowDomainUser = $true
            }; 
        );    
    }

MDTServer -DomainAdminCredential $domainAdmin -DomainName "mdt.aberdean.local" -InterfaceAlias "Ethernet" -IPv4Address "192.168.170.30" -DNSServers "192.168.170.5" -Gateway "192.168.170.1" -ConfigurationData $ConfigData