#################################################################
#   Set a persistent scratch location for ESXi                  #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Jul 11 2019                                 #
#################################################################
# This script is used to setup persistant scratch in VMware ESXi.
# vCLI must be installed on your system for this script to work properly.

# Variables
$esxiip = Read-Host "What is the IP address of the host you would like to modify"
$esxhostname = Read-Host "What is the host's name?"
# $esxipassword = Read-Host "What is the root password" -assecurestring

# Check if vCLI is installed.
$vclipath = Test-Path -path "C:\Program Files\VMware\VMware vSphere CLI"
If($vclipath -eq $true){
    Write-Host = "vCLI is installed"
    sl $vclipath
}
Else{
    Write-Error = "vCLI doesn't seem to be installed. Please install from https://code.vmware.com/web/tool/6.7/vsphere-cli'
    or Modify the vclipath variable in this script to reflect your install location."
    Exit
}

# Check current scratch location and move if needed.
$currentscratch = & vicfg-advcfg.pl --$esxiip --username root -g ScratchConfig.ConfiguredScratchLocation
If ($currentscratch -like "/tmp*"){
    Write-host "Scratch is non-persistant, moving to datastore"
    # Connect to ESXi host and retrieve datastores list.
    & vifs.pl --$esxiip --username root --listds
    $datastore = Read-Host "What persistant datadstore would you like to use for storage?"
    # Create the folders
    & vifs.pl --$esxiip --username root --mkdir "[$datastore] .locker-$esxhostname"
    & vicfg-advcfg.pl --$esxiip --username root -s /vmfs/volumes/$datastore/.locker-$esxhostname ScratchConfig.ConfiguredScratchLocation
    Write-Host "Scratch has been successfully moved. Please put the host into maintainence mode and reboot"
}
Else {
    $answer = Read-host "Scratch is already off local media, would you like to move it anyway? Y/N"
    If ($answer -like "y"){
        # Connect to ESXi host and retrieve datastores list.
        & vifs.pl --$esxiip --username root --listds
        $datastore = Read-Host "What persistant datadstore would you like to use for storage?"
        # Create the folders
        & vifs.pl --$esxiip --username root --mkdir "[$datastore] .locker-$esxhostname"
        & vicfg-advcfg.pl --$esxiip --username root -s /vmfs/volumes/$datastore/.locker-$esxhostname ScratchConfig.ConfiguredScratchLocation
        Write-Host "Scratch has been successfully moved. Please put the host into maintainence mode and reboot"
    }
    Else {Exit}
}
