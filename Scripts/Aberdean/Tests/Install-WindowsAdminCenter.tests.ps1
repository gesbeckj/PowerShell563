$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Describe "Install-WindowsAdminCenter Tests" {
    It "Script Should Exists" {
        (Test-Path "$here\..\Install-WindowsAdminCenter.ps1") | Should Be $True
    }
    It "Should not throw"{
        {&"$here\..\Install-WindowsAdminCenter.ps1"} |  Should Not Throw
    }
    It "Should create installer log file"{
        (Test-Path $env:TEMP\log.txt) | Should be $True
    }
    It "Should automatically delete the installer download"{
        (Test-Path "$env:TEMP\WindowsAdminCenter.msi") | Should be $False
    }
    It "Windows Admin Center should be listening on TCP port"{
        Test-NetConnection -ComputerName localhost -Port 443 | Should Be $True
    }
}