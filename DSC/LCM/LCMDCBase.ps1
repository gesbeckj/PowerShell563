[DSCLocalConfigurationManager()]
Configuration LCM {
    param
    (
        [Parameter(Mandatory=$True)]
        [PSCredential]$RegistrationKey
    )
    Node localhost {
        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode = 'Pull'
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
        }
        ConfigurationRepositoryWeb DSCPullServer {
            ServerURL = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey = $RegistrationKey.GetNetworkCredential().Password
            ConfigurationNames = @('BaseOSConfig', 'EnableRDP','AzureDC')
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
        PartialConfiguration BaseOSConfig {
            ConfigurationSource = "[ConfigurationRepositoryWeb]DSCPullServer"
        }
        PartialConfiguration EnableRDP {
            ConfigurationSource = "[ConfigurationRepositoryWeb]DSCPullServer"
        }
        PartialConfiguration DSCADInstall {
            ConfigurationSource = "[ConfigurationRepositoryWeb]DSCPullServer"
        }
    }
}