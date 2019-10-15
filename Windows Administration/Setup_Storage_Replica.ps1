#################################################################
#   Setup MS Storage Replica Server 2016                        #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Jul 22 2018                                 #
#################################################################
# This script is used to setup Volume Replication in Server 2016. Volume replication can be used in place of
# DFS-R or a robocopy sync script, however it is recommended to know the cavieats before replacing traditional
# tree mirroring with block mirroring.

# Variables.
$sourcepc = Read-Host "Source PC Name?"
$sourcereplvol = Read-Host "Which volume would you like to replicate?"
$sourcelogvol = Read-Host "Which volume will hold the logs?"
$sourcereplname = Read-Host "What would you like the source replication group name to be?"
$destepc = Read-Host "Destination PC Name?"
$destreplvol = Read-Host "Which volume will hold the replication data?"
$destlogvol = Read-Host "Which volume will hold the logs on the destination?"
$destreplname = Read-Host "What would you like the destination replication group name to be?"
$Servers = $sourcepc,$destepc

# Install Roles.
Write-Warning "Installing Roles on both servers now. The -restart flag is in use. Hosts may reboot."

$Servers | ForEach { 
    Install-WindowsFeature -ComputerName $_ -Name Storage-Replica,FS-FileServer -IncludeManagementTools -restart 
}

# Test Replication Topology.
If(!Test-Path -path C:\Temp){
    md C:\Temp
}
sl C:\Temp
Write-Host "Testing Replication Topology. The results will display once complete."
Test-SRTopology -SourceComputerName $sourcepc -SourceVolumeName $sourcereplvol -SourceLogVolumeName $sourcelogvol -DestinationComputerName $destepc -DestinationVolumeName $destreplname -DestinationLogVolumeName $destlogvol -DurationInMinutes 3 -ResultPath c:\temp
Invoke-Expression .\TestSrTopologyReport*

# Set replication Variables.


New-SRPartnership -SourceComputerName $sourcepc -SourceRGName $sourcereplname -SourceVolumeName $sourcereplvol -SourceLogVolumeName $sourcelogvol -DestinationComputerName $destepc -DestinationRGName $destreplname -DestinationVolumeName $destreplvol -DestinationLogVolumeName $destlogvol 


