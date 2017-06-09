<#
.SYNOPSIS
This creates a MOF file for DSC for the setting the second disk as a data disk D:\
.DESCRIPTION
This creates a MOF file for DSC for the setting the second disk as a data disk D:\
.EXAMPLE
DSCServerDataDisk.ps1 -ComputerName "Server" -outputpath "C:\DSC\"
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

Configuration DSCServerDataDisk {
param(

#ComputerName
[string[]]$ComputerName="localhost"
)

Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
Import-DscResource -Module xStorage
Node $ComputerName
{        
        xWaitforDisk Disk1
        {
             DiskID = 1
             RetryIntervalSec = 60
             RetryCount = 60
        }
        xDisk DVolume
        {
            DiskID = 1
            DriveLetter = 'D'
            FSLabel = 'Data'
        }
}

}
DSCServerDataDisk -ComputerName $ComputerName -OutputPath $path