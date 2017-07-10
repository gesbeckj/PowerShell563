<#
.SYNOPSIS
This creates a MOF file for DSC for the base OS configuration. 
.DESCRIPTION
This creates a MOF file for DSC for disabling UAC, enabling IEEsc and setting hte timezone. 
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
            Setting = 'NeverNotify'
        }
        xIEEsc IEEscAdmin
        {
            UserRole = 'Administrators'
            IsEnabled = $false
        }
        xIEEsc IEEscUsers
        {
            UserRole = 'Users'
            IsEnabled = $false
        }
        xTimeZone TimeZone
        {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'
        }
}
}

BaseOSConfig -ComputerName $ComputerName -OutputPath $path