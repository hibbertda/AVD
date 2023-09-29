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


# cjzRx4xi%9e^N3@^&T