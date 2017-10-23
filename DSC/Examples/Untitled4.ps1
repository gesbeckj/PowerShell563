$ConfigData= @{ 
    AllNodes = @(     
            @{  
                # The name of the node we are describing 
                NodeName = "MGMT-SQL-00" 
                # The path to the .cer file containing the 
                # public key of the Encryption Certificate 
                # used to encrypt credentials for this node 
                CertificateFile = "C:\Users\james_000\Desktop\MGMT-SQL-00_PublicCert.cer"
                # The thumbprint of the Encryption Certificate 
                # used to decrypt the credentials on target node 
                Thumbprint = '64dfefc47ac757a956170dbc4873d81332101d8b'
                PSDSCAllowDomainUser = $true
            }; 
        );    
    }
$domainName = "mgmt.local"

$adminPass =  ConvertTo-SecureString "Gesbeck1" -AsPlainText -Force
$servicePass =  ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainAdmin =  New-Object System.Management.Automation.PSCredential ("mgmt\administrator", $adminpass)
$SqlServiceCredential = New-Object System.Management.Automation.PSCredential ("mgmt\sqlserviceuser", $adminpass)
$SqlAgentServiceCredential = New-Object System.Management.Automation.PSCredential ("mgmt\sqlagentserviceuser", $adminpass)
$SqlAdministratorCredential = New-Object System.Management.Automation.PSCredential ("mgmt\sqladmin", $adminpass)

