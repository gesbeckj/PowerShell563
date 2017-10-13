Configuration MDTServer {
    param(
    #ComputerName
    [string[]]$ComputerName="localhost",
    
    #Domain Admin Credential
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [System.Management.Automation.PSCredential]
    $DomainAdminCredential,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [String]
    $DomainName,

    #InterfaceAlias defaults to Ethernet
    [string]$InterfaceAlias="Ethernet",
    #IPAddress
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $IPv4Address,
    #PrefixLength defaults to 24
    [uint32]$PrefixLength="24",
    #Gateway
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $Gateway,
    #DNSServers
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String[]] $DNSServers
    )
    
    Import-DscResource -Module xSystemSecurity, xTimeZone
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xComputerManagement
    
    Node $ComputerName
    {
            xUAC UAC
            {
                Setting = 'NotifyChanges'
            }
            xIEEsc IEEscAdmin
            {
                UserRole = 'Administrators'
                IsEnabled = $True
            }
            xIEEsc IEEscUsers
            {
                UserRole = 'Users'
                IsEnabled = $True
            }
            xTimeZone TimeZone
            {
                TimeZone = 'Central Standard Time'
                IsSingleInstance = 'Yes'
            }
            xRemoteDesktopAdmin RemoteDesktopSettings
            {
               Ensure = 'Present'
               UserAuthentication = 'Secure'
            }
            xFirewall AllowRDP
            {
                DisplayName = 'DSC - Remote Desktop Admin Connections'
                Name = "Remote Desktop"
                Ensure = 'Present'
                Enabled = 'True'
            }
            xServiceSet TermServ
            {
                Name = "TermService"
                StartupType = "Automatic"
                State = "Running"
                Ensure = "Present"
            }
            xComputer JoinDomain
           { 
                DomainName = $DomainName
                Credential = $DomainAdminCredential
                Name = "MDT01"
            }
            WindowsFeature "NET-Framework-Core"
            {
                Ensure = "Present"
                Name = "NET-Framework-Core"
            }
            WindowsFeature 'NetFramework45'
            {
                Name   = 'NET-Framework-45-Core'
                Ensure = 'Present'
            }
            WindowsFeature 'FS-Data-Deduplication'
            {
                Name   = 'FS-Data-Deduplication'
                Ensure = 'Present'
            }  
            WindowsFeature 'WDS'
            {
                Name   = 'WDS'
                Ensure = 'Present'
                IncludeAllSubFeature = $true
            }
            WindowsFeature 'WDS-AdminPack'
            {
                Name   = 'WDS-AdminPack'
                Ensure = 'Present'
            }
            File WindowsDeploymentServicesFolder
            {
                DependsOn = "[WindowsFeature]WDS"
                DestinationPath = "D:\RemoteInstall"
                Ensure = "Present"
                Type = "Directory"
            }
            Script WindowsDeploymentServicesInitializeServer
            {
                DependsOn = "[File]WindowsDeploymentServicesFolder"
                TestScript = {
                    $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
                    return ($WdsServer.SetupManager.InitialSetupComplete)
                }
                SetScript = { 
                    Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                        -ArgumentList "/Initialize-Server", "/REMINST:D:\RemoteInstall"
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Credential = $Credential
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            # WDS Configure DHCP settings
            Script WindowsDeploymentServicesConfigureDhcpProperties
            {
                DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
                TestScript = {
                    $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
                    
                    $SetupManager = $WdsServer.SetupManager
                    return (
                            $WdsServer.ConfigurationManager.PxeBindPolicy.UseDhcpPorts -eq $true `
                            -and $SetupManager.DhcpOperationMode -eq "0"
                        )
                }
                SetScript = { 
                    Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                        -ArgumentList "/Set-Server", "/UseDhcpPorts:Yes", "/DhcpOption60:No"
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            Script WindowsDeploymentServicesAuthorizeDHCP
            {
                DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
                TestScript = {
                    $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
                    #$SetupManager = $WdsServer.SetupManager
                    return $WdsServer.ConfigurationManager.AuthorizedForDhcp
                }
                SetScript = { 
                    Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                        -ArgumentList "/Set-Server", "/Authorize:Yes"
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            Script WindowsDeploymentServicesAcceptAllClients
            {
                DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
                TestScript = {
                    $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
                    #$SetupManager = $WdsServer.SetupManager
                    return $WdsServer.ConfigurationManager.DeviceAnswerPolicy.AnswerClients
                }
                SetScript = { 
                    Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                        -ArgumentList "/Set-Server", "/AnswerClients:All"
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            Script WindowsDeploymentServicesAlwaysBootPXE
            {
                DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
                TestScript = {
                    $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
                    #$SetupManager = $WdsServer.SetupManager
                    return (($WdsServer.ConfigurationManager.BootProgramPolicy.KnownClientPxePromptPolicy -eq 2) -and ($WdsServer.ConfigurationManager.BootProgramPolicy.NewClientPxePromptPolicy -eq 2))
                }
                SetScript = { 
                    Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                        -ArgumentList "/Set-Server", "/PxePromptPolicy", "/Known:NoPrompt", "/New:NoPrompt"
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            Script InstallADK
            {
                DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
                TestScript = {
                    $ADKStatus = get-itemproperty hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\* | Where-Object {$_.DisplayName -like "Windows Assessment and Deployment Kit - Windows 10"}
                    return ($ADKStatus -ne $null)
                }
                SetScript = { 
                    $url = "https://go.microsoft.com/fwlink/p/?LinkId=845542"
                    if (!(Test-Path -path "C:\Temp")) {New-Item -path "C:\Temp" -ItemType Directory}
                    $output = "C:\Temp\ADKsetup.exe"
                    Invoke-WebRequest -uri $url -OutFile $output
                    $cmd = "C:\Temp\adksetup.exe"
                    $args = '/quiet /installpath "D:\Program Files (x86)\Windows Kits\10" /features OptionId.DeploymentTools OptionID.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool /ceip off'
                    Start-Process -FilePath $cmd -ArgumentList $args -Wait
                }
                GetScript = {
                    return @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = (Invoke-Expression $TestScript)
                    }
                }
            }
            xRemoteFile DaRTInstaller
            {
                DestinationPath = "C:\Temp\msdart100.msi"
                URI = "https://pull.gesbeck.tk/repo/msdart100.msi"
            }
            xMsiPackage InstallDaRT
            {
                ProductID = "{60B7DCA9-BCE9-4FBD-A550-3CC8E0F3A933}"
                Path = "C:\Temp\msdart100.msi"
                Ensure = 'Present'
                Arguments = 'TARGETDIR="D:\Program Files\Microsoft DaRT" INSTALLDIR="D:\Program Files\Microsoft DaRT"'
            }
            xRemoteFile MDTInstaller
            {
                DestinationPath = "C:\Temp\MDT.msi"
                URI = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
            }
            xMsiPackage InstallMDT
            {
                ProductID = "{9547DE37-4A70-4194-97EA-ACC3E747254B}"
                Path = "C:\Temp\MDT.msi"
                Ensure = 'Present'
                Arguments = 'TARGETDIR="D:\Program Files\Microsoft Deployment Toolkit" INSTALLDIR="D:\Program Files\Microsoft Deployment Toolkit"'
            }
            xDhcpClient DisableDhcpClient4
            {
                State          = 'Disabled'
                InterfaceAlias = 'Ethernet'
                AddressFamily  = 'IPv4'
            }
            xDhcpClient DisableDhcpClient6
            {
                State          = 'Disabled'
                InterfaceAlias = 'Ethernet'
                AddressFamily  = 'IPv6'
            }
            xIPAddress setIPAddress
            {
                IPAddress = $IPv4Address
                InterfaceAlias = $InterfaceAlias
                AddressFamily = "IPv4"
                PrefixLength = $PrefixLength
            }
            xDefaultGatewayAddress setDefaultGateway
            {
                AddressFamily = "IPv4"
                InterfaceAlias = $InterfaceAlias
                Address = $Gateway
                DependsOn = "[xIPAddress]setIPAddress"
            }
            xDNSServerAddress setDNSServer
            {
                InterfaceAlias = $InterfaceAlias
                AddressFamily = "IPv4"
                Address = $DNSServers
                Validate = $false
            }
    }
}