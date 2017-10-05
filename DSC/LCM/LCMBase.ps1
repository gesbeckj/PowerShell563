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
#LCM -RegistrationKey (Get-Credential) -thumbprint ‎"F7F03D17AF2FA167200D84CB78487B2E8835F698" -ConfigName 'MDTServer'