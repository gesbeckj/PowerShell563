<#
.SYNOPSIS
This script returns configuration informatoin for a Windows Server. 
.DESCRIPTION
This script returns configuration informatoin for a Windows Server. 
.EXAMPLE
ServerOSAudit.ps1
.NOTES
#>

$wmibios = Get-WmiObject Win32_BIOS -ErrorAction Stop | Select-Object version,serialnumber 
$wmisystem = Get-WmiObject Win32_ComputerSystem -ErrorAction Stop | Select-Object *
$wmios = Get-WmiObject Win32_OperatingSystem -ErrorAction Stop | Select-Object *
$wmicpu = get-wmiobject win32_processor | select *
$computer = $env:COMPUTERNAME
    $ResultProps = @{
        ComputerName = $computer 
        BIOSVersion = $wmibios.Version 
        SerialNumber = $wmibios.serialnumber 
        Manufacturer = $wmisystem.manufacturer 
        Model = $wmisystem.model 
        IsVirtual = $false 
        VirtualType = $null 
    }
    if ($wmibios.SerialNumber -like "*VMware*") {
                    $ResultProps.IsVirtual = $true
                    $ResultProps.VirtualType = "Virtual - VMWare"
                }
                else {
                    switch -wildcard ($wmibios.Version) {
                        'VIRTUAL' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Hyper-V" 
                        } 
                        'A M I' {
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Virtual PC" 
                        } 
                        '*Xen*' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Xen" 
                        }
                    }
                }
                if (-not $ResultProps.IsVirtual) {
                    if ($wmisystem.manufacturer -like "*Microsoft*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - Hyper-V" 
                    } 
                    elseif ($wmisystem.manufacturer -like "*VMWare*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - VMWare" 
                    } 
                    elseif ($wmisystem.model -like "*Virtual*") { 
                        $ResultProps.IsVirtual = $true
                        $ResultProps.VirtualType = "Unknown Virtual Machine"
                    }
                }

write-host "Server Name:" $env:COMPUTERNAME
Write-Host "Is Virtual? " $ResultProps.IsVirtual
write-host "Virtualization Type: " $ResultProps.VirtualType
Write-host "Operating System:" $wmios.Caption
# TODO: WSUS Settings
$memory = [math]::Round(($wmisystem.TotalPhysicalMemory / 1GB), 2)
write-host "Memory Allocation:" $memory "GB"
Write-Host "Processor:" $wmicpu.Name
write-host "Total Cores:" $wmicpu.NumberOfLogicalProcessors
$ip=get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1}
write-host "Network Adapter and IP Adderss"
$ip | select Description, IPAddress
write-host
write-host "Installed Roles & Features"

get-windowsfeature | where Installed | select Name | fl
write-host "Drive Information"
get-volume 

write-host "Page File Location"
Get-WmiObject Win32_PageFileusage

write-host "DNS Servers"
Get-DnsClientServerAddress | Select-Object –ExpandProperty ServerAddresses