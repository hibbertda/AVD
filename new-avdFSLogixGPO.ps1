<#
.SYNOPSIS
	Creates a new GPO and sets the FSLogix registry settings for use with Azure Virtual Desktop.

.DESCRIPTION
    This script will create a new GPO and set the FSLogix registry settings for use with Azure Virtual Desktop.
    The script will prompt for the name and comment of the GPO, and the target OU to link the GPO to.
    The script will also prompt for the path to the FSLogix Profile Container share.
    The script will then create the GPO, set the FSLogix registry settings, and link the GPO to the target OU.
	
.PARAMETER target_ou_DN
    The target OU to link the GPO to. The default value is "OU=MyOU,DC=contoso,DC=com".

.PARAMETER gpo_name
    The name of the GPO to create. The default value is "FSLogix Configuration".

.PARAMETER gpo_comment
    The comment of the GPO to create. The default value is "FSLogix Configuration for use with Azure Virtual Desktop".

.EXAMPLE
    .\new-avdFSLogixGPO.ps1 -target_ou_DN "OU=MyOU,DC=contoso,DC=com" -gpo_name "FSLogix Configuration" -gpo_comment "FSLogix Configuration for use with Azure Virtual Desktop"
#>

param(
    [Parameter(Mandatory=$false)][string]$target_ou_DN = "OU=MyOU,DC=contoso,DC=com",
    [Parameter(Mandatory=$false)][string]$gpo_name = "FSLogix Configuration",
    [Parameter(Mandatory=$false)][string]$gpo_comment = "FSLogix Configuration for use with Azure Virtual Desktop"
)

<# 
Set the FSLogix registry settings in the GPO
Honestly I forgot how to do some PowerShell Object stuff, so I just used JSON to make it easier for me to read.
Update the settings below to match your environment, remeber to use double backslashes to escape backslashes.

EXAMPLE: Escaping a SMB share path

    "\\\\myserver\\myshare\\profiles"

#>
$Registry_JSON = @"
[
    {
        "value" : 1,
        "valueName" : "Enabled",
        "type" : "DWORD",
        "key" : "HKLM\\SOFTWARE\\FSLogix\\Profiles"
    },
    {
        "value" : "\\\\server.domain.com\\FSLogix\\ProfileContainer",
        "valueName" : "VHDLocations",
        "type" : "STRING",
        "key" : "HKLM\\SOFTWARE\\FSLogix\\Profiles"
    },
    {
        "value" : 1,
        "valueName" : "Enabled",
        "type" : "DWORD",
        "key" : "HKLM\\SOFTWARE\\FSLogix\\Logging"
    },
    {
        "value" : "C:\\FSLogix\\Logs",
        "valueName" : "LogDir",
        "type" : "STRING",
        "key" : "HKLM\\SOFTWARE\\FSLogix\\Logging"
    },
    {
        "value" : 30,
        "valueName" : "LogFileKeepingPeriod",
        "type" : "DWORD",
        "key" : "HKLM\\SOFTWARE\\FSLogix\\Logging"
    }
]
"@

# Import the Group Policy module
Import-Module GroupPolicy
import-module ActiveDirectory

# Check to see if the OU exists
try {
    write-host -foregroundcolor green "Checking to see if the target OU exists..." -nonewline
    $ou = Get-ADOrganizationalUnit -identity $target_ou_DN
    if ($ou) {
        write-host -foregroundcolor yellow "The target OU exists!"
    }
}
catch {
    write-host -ForegroundColor red "NOPE!"
    write-error -Message "The target OU does not exist" `
        -Category ObjectNotFound
    exit
}

# Create a new GPO
write-host -foregroundcolor yellow "Creating new GPO..." -nonewline
try {
    $gpo = New-GPO -Name $gpo_name -ErrorAction stop `
        -comment $gpo_comment
    write-host -foregroundcolor green "GPO created!"
}
catch {
    write-error -Message "Unable to create GPO `n $_"   
    exit
}

# Convert the JSON to a PowerShell object
$fslogix_registry_settings = $Registry_JSON | ConvertFrom-Json

# Loop through the registry settings and set them in the GPO
write-host -foregroundcolor yellow "Setting registry values in GPO..." -nonewline
$fslogix_registry_settings | ForEach-Object { 
    Set-GPRegistryValue -name $gpo.DisplayName `
        -key $_.key `
        -valueName $_.valueName `
        -type $_.type `
        -value $_.value | out-null
    }
write-host -foregroundcolor green "Registry values set!"

# Link the GPO to an Active Directory container
write-host -foregroundcolor yellow "Linking GPO to $target_ou_DN..." -nonewline
New-GPLink -Name $gpo.DisplayName -Target $target_ou_DN
write-host -foregroundcolor green "GPO linked!"