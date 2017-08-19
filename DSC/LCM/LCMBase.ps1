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
            ConfigurationNames = @('BaseOSConfig', 'EnableRDP')
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
            RefreshMode = 'Pull'
        }
        PartialConfiguration EnableRDP {
            ConfigurationSource = "[ConfigurationRepositoryWeb]DSCPullServer"
            RefreshMode = 'Pull'
        }
        PartialConfiguration ServerNetworkConfig {
            ConfigurationSource = '[PartialConfiguration]ServerNetworkConfig'
            RefreshMode = 'Push'
        }
    }
}