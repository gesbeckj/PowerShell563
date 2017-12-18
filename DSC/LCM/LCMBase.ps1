[DSCLocalConfigurationManager()]
Configuration LCM {
    param
    (
        [Parameter(Mandatory = $True)]
        [PSCredential]$RegistrationKey,

        [Parameter(Mandatory = $True)]
        [string]$thumbprint,

        [Parameter(Mandatory = $True)]
        [string]$ConfigName
    )
    Node localhost {
        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode = 'Pull'
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
            CertificateID = $thumbprint;
        }
        ConfigurationRepositoryWeb DSCPullServer {
            ServerURL = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey = $RegistrationKey.GetNetworkCredential().Password
            ConfigurationNames = @($ConfigName)
        }
        ResourceRepositoryWeb PullServerModules {
            ServerURL = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey = $RegistrationKey.GetNetworkCredential().Password
        }
        ReportServerWeb PullServerReporting
        {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey.GetNetworkCredential().Password
        }
        PartialConfiguration $ConfigName {
            ConfigurationSource = "[ConfigurationRepositoryWeb]DSCPullServer"
            RefreshMode = 'Pull'
        }
    }
}
LCM -RegistrationKey (Get-Credential) -thumbprint ‎"‎‎‎‎0b01812952665674b12f0bc9e8c9e62f6c87bf9a" -ConfigName 'DINO-DC2'
