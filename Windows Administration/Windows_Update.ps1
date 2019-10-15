#################################################################
#   Automatic Windows Update Install                            #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Sept 10 2019                                #
#################################################################
# This script is used to automatically install windows updates.
# All dependencies will be automatically installed if they don't exist. 

# Check that the Module exists.
If (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Write-Host "Module installed"
} 
Else {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.0.5.201 -Force
    Install-Module PSWindowsUpdate
}

# Check if Microsoft Update Service is added to WUServiceManager
Try{
    Get-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
}
Catch{
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
}

# Install all avalible updates and reboot
Install-Windowsupdate –MicrosoftUpdate -Install –AcceptAll –AutoReboot