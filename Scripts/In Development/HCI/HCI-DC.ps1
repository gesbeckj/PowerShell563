Get-WindowsFeature *Domain-Services* | Add-WindowsFeature -IncludeManagementTools
$Credential = Get-Credential -Message "Leave username blank, enter Safe Mode Password"
Install-ADDSForest -CreateDnsDelegation:$false -DomainMode WinThreshold -DomainName "HCI.local" -DomainNetbiosName "HCI"-ForestMode WinThreshold -InstallDns -Force -SafeModeAdministratorPassword $Credential.Password -NoRebootOnCompletion