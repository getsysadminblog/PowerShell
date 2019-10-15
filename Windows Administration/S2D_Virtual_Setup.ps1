# Install Cluster, and iSCSI roles
Install-WindowsFeature -Name File-Services, Failover-Clustering, FS-iSCSITarget-Server -IncludeManagementTools -ComputerName HC-Node1
Install-WindowsFeature -Name File-Services, Failover-Clustering, FS-iSCSITarget-Server -IncludeManagementTools -ComputerName HC-Node2

# Configure Cluster
New-Cluster -Name iSCSI -Node ctj-iscsi01.ctj.lan, ctj-iscsi02.ctj.lan -NoStorage -StaticAddress 192.168.1.11

# Ensure "CanPool" eq $true
Get-PhysicalDisk

# Configure S2D
Enable-ClusterS2D -SkipEligibilityChecks -Autoconfig:0 -confirm:$false -PoolFriendlyName S2D -CacheState Disabled -verbose
Get-StoragSsubSystem clus* | Set-StorageHealthSetting -name “System.Storage.PhysicalDisk.AutoReplace.Enabled” -value “False”

# Set Unknowns to SSD
Get-PhysicalDisk | Where MediaType -eq "UnSpecified" | Set-PhysicalDisk -MediaType SSD

# Build the storage pool.
New-StoragePool -StorageSubSystemFriendlyName *Cluster* -FriendlyName S2D -ProvisioningTypeDefault Fixed -PhysicalDisk (Get-PhysicalDisk | ? CanPool -eq $true)

# Verify Cluster S2D is correct
Get-ClusterS2D 
CacheMetadataReserveBytes : 34359738368
CacheModeHDD              : ReadWrite
CacheModeSSD              : WriteOnly
CachePageSizeKBytes       : 16
CacheState                : Disabled
Name                      : iSCSI
ScmUse                    : Cache
State                     : Enabled

