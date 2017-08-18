$ConfigData= @{ 
    AllNodes = @(     
            @{  
                # The name of the node we are describing 
                NodeName = "MGMT-SQL-00" 

                # The path to the .cer file containing the 
                # public key of the Encryption Certificate 
                # used to encrypt credentials for this node 
                CertificateFile = "C:\Users\james.gesbeck\AppData\Local\Temp\DscPublicKey.cer" 


                # The thumbprint of the Encryption Certificate 
                # used to decrypt the credentials on target node 
                Thumbprint = '64dfefc47ac757a956170dbc4873d81332101d8b'
                PSDSCAllowDomainUser = $true
            }; 
        );    
    }

$domainName = "mgmt.local"
$DomainAdmin = Get-Credential
$SqlServiceCredential = Get-Credential
$SqlAgentServiceCredential = Get-Credential
$SqlAdministratorCredential = Get-Credential

