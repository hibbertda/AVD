# Azure Virtual Desktop (AVD)

## Scripts

I have a collection of scripts I have created to assist with the deployment and configuration of AVD.

### New-avdFSLogixGPO.ps1

PowerShell script to create an Active Directory (AD DS) Group Policy (GPO) to configure FSLogix profile persistence for Windows session hosts. 

|Parameter|Description|
|---|---|
|target_ou_DN|Disginguished Name (DN) for an OU to link the GPO|
|gpo_name|GPO Display Name|
|gpo_description|GPO Description|

#### Example:
```powershell

.\new-avdFSLogixGPO.ps1 -target_ou_DN "OU=MyOU,DC=contoso,DC=com" -gpo_name "FSLogix Configuration" -gpo_comment "FSLogix Configuration for use with Azure Virtual Desktop"

```

The script is preloaded with the basic registry settings to enable FSLogix. The settings are stored in a JSON array inside of the script. Additional settings can be added.

```JSON
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

```

### New-avdFSLogix_registry

PowerShell script to directly create FSLogix configuration settings in the registry on a Windows session host. The **values** are default/generic and need to be updated to match your actual values.

```powershell

# Set registry settings for FSLogix configuration used with Azure Virtual Desktop

# Enable Profile Container
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "Enabled" -Value 1 -PropertyType DWORD -Force
# This setting enables the use of the FSLogix Profile Container, which stores user profiles in a virtual hard disk (VHD) file.

# Set Profile Container location
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -Value "C:\FSLogix\ProfileContainer.vhdx" -PropertyType String -Force
# This setting specifies the location of the Profile Container VHD file.

# Enable Office 365 Container
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Office365" -Name "Enabled" -Value 1 -PropertyType DWORD -Force
# This setting enables the use of the FSLogix Office 365 Container, which stores user Office 365 data in a VHD file.

# FSlogix Logging Enbaled
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Logging" -Name "Enabled" -Value 1 -PropertyType DWORD -Force
# This setting enables the use of the FSLogix Log file, which stores log data in a VHD file.

# Set FSlogix Log location
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Logging" -Name "LogDir" -Value "C:\FSLogix\Logs" -PropertyType String -Force
# This setting specifies the location of the FSLogix Log file.

# Set FSLogix Log Retention Period
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Logging" -Name "LogFileKeepingPeriod" -Value 30 -PropertyType DWORD -Force
# This setting specifies the retention period of the FSLogix Log file.

```