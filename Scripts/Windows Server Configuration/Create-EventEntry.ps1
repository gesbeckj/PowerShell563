<#
.SYNOPSIS
This creates an error event entry in the application log with the specified source and message. 
.DESCRIPTION
This creates an error event entry in the application log with the specified source and message. 
.EXAMPLE
Create-EventEntry -Source "Test" -Message "This is a test application error message"
.NOTES
Must run with local administrator privileges.
#>
[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Source,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Message
)
New-EventLog -LogName Application -Source $source -ErrorAction Continue
Write-EventLog -LogName Application -Source $Source -EventId 66 -EntryType Error -Message $Message