<#
.SYNOPSIS
This creates a MOF file for DSC for the base OS configuration. 
.DESCRIPTION
This creates a MOF file for DSC for enabling UAC, enabling IEEsc and setting the timezone. 
.EXAMPLE
DSCServerOSConfig.ps1 -ComputerName 'Server'
#>
[CmdletBinding()]
param(
#ComputerName
[string[]]$ComputerName="localhost",

#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)

Configuration BaseOSConfig {
param(
#ComputerName
[string[]]$ComputerName="localhost"
)

Import-DscResource -Module xSystemSecurity, xTimeZone
Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Node $ComputerName
{        
        xUAC UAC
        {
<<<<<<< HEAD
            Setting = 'AlwaysNotify'
=======
            Setting = 'NotifyChanges'
>>>>>>> bfef710bcee16a146c120acd0b6b64b811e43a7b
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
}
}

BaseOSConfig -ComputerName $ComputerName -OutputPath $path