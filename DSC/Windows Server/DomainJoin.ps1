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

#DomainJoin Credential
[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.PSCredential]
$Credential,

#Output Path
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[String] $Path
)

Configuration DomainJoin {
param(
#ComputerName
[string[]]$ComputerName="localhost",
[Parameter(Mandatory = $true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.PSCredential]
$Credential
)

Import-DscResource -Module xComputerManagement
Node $ComputerName
{        
        xComputer JoinDomain
       {
        DomainName = "management.local"
            Credential = $cred
            Name = "MGMT-SQL"
        }
}
}

