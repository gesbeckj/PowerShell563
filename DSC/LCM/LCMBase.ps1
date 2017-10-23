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
LCM -RegistrationKey (Get-Credential) -thumbprint ‎"‎F931BAC3A8F6909CC79FD25565E609A469C7393B" -ConfigName 'DINO-Sync'
