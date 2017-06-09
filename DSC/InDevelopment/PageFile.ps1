configuration DSCPageFile
{
param(


[string[]]$ComputerName="localhost"
)

node $ComputerName
{
Script PageFile
{


    SetScript = {
        $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
        $System.AutomaticManagedPagefile = $False
        $System.Put()   
        Set-WMIInstance -class Win32_PageFileSetting -Arguments @{name="C:\pagefile.sys";InitialSize = 800;MaximumSize =800}  -ErrorAction Ignore -WarningAction Ignore
        $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
        $CurrentPageFile.InitialSize = [int]800
        $CurrentPageFile.MaximumSize = [int]800
        $CurrentPageFile.Put()
        Set-WMIInstance -class Win32_PageFileSetting -Arguments @{name="d:\pagefile.sys";InitialSize = 0;MaximumSize =0} -ErrorAction Ignore -WarningAction Ignore
        $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='d:\\pagefile.sys'"
        $CurrentPageFile.InitialSize = [int]0
        $CurrentPageFile.MaximumSize = [int]0
        $CurrentPageFile.Put()
    }
    TestScript = {
      return (((gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'").maximumsize.tostring().equals('800') -and (gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'").initialsize.tostring().equals('800')) -and ((gwmi -query "select * from Win32_PageFileSetting where name='d:\\pagefile.sys'").maximumsize.tostring().equals('0') -and (gwmi -query "select * from Win32_PageFileSetting where name='d:\\pagefile.sys'").initialsize.tostring().equals('0')))

    }
    GetScript = {
      # Do Nothing
    }
}
}
}