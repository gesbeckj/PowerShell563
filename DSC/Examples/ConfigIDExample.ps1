[DSCLocalConfigurationManager()]
Configuration LCM {
    Node localhost {
        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode = 'Pull'
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
            ConfigurationID = 'f3f8b2bd-ac0d-4f11-be1c-79b14cddebb5'
        }
        ConfigurationRepositoryWeb DSCPullServer {
            ServerURL = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
        }
        ResourceRepositoryWeb PullServerModules {
            ServerURL = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
        }
        ReportServerWeb PullServerReporting
        {
            ServerUrl = 'https://pull.gesbeck.tk:8080/PsDscPullserver.svc'
        }
    }
}