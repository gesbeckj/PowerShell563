[CmdletBinding()]
Param (
[string]
$WindowsAdminCenterDownloadSource = "http://aka.ms/WACDownload",

[string]
$DownloadDestination = "C:\WindowsAdminCenter.msi",

[int]
$WindowsAdminCenterHTTPSPort = 443
)
Process 
{
    if (!(Test-Path (Split-Path $DownloadDestination)))
    {
        Write-Error "The specified folder for downloading the file does not exist. Please create the folder and try again."
        return
    }
    Write-Verbose "Downloading Windows Admin Center from $WindowsAdminCenterDownloadSource"
    Write-Verbose "Downloading Windows Admin Center to $DownloadDestination"
    $client = new-object System.Net.WebClient
    try {
        $client.DownloadFile($WindowsAdminCenterDownloadSource,$DownloadDestination)
    }
    catch {
        Write-Error $Error[0]
    }
    if (!(Test-Path $DownloadDestination))
    {
        Write-Error "An unknown error occuring. The installer is not at $DownloadDestination as expected"
        return
    }
    Write-Verbose "Starting Windows Admin Center Install. Logging install to C:\log.txt"
    Start-Process msiexec.exe -Wait -ArgumentList "/i $DownloadDestination /qn /L*v c:\log.txt SME_PORT=$WindowsAdminCenterHTTPSPort SSL_CERTIFICATE_OPTION=generate"
    Remove-Item $DownloadDestination
    Remove-Item 'c:\log.txt'
}