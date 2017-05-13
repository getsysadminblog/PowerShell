#################################################
#   Remove all snapshots from Hyper-V           #
#   Created by - Cameron Joyce                  #
#   Last Modified - May 13 2017                 #
#################################################
# This script is designed to be a daily job to remove snapshots from a single Hyper-V host.

# Input Parameters
param (
    [string]$hours = 24
    [string]$outfile = $null
)

# Variables
$time = (Get-Date).AddMinutes(-$hours)

# Load Modules
Import-Module Hyper-V

# Find all snapshots and load them into an Array.
$vms = Get-VM | Where { $_.State –eq ‘Running’ } 

# For each running VM, list snapshots.
Foreach($vm in $vms){
    $snapshots = Get-VMSnapshot -VMName TestVM | Where-Object {$_.CreationTime -lt $time } | FT
    Write-Host "The following snapshots are older than $hours and will be deleted"
    Write-Output $snapshots
    Write-Output $snapshots | Out-File $outfile -append
}

# Delete Snapshots for all VMs.
Foreach($vm in $vms){
    Get-VMSnapshot -VMName TestVM | Where-Object {$_.CreationTime -lt $time } | Remove-VMSnapshot
}

# Verify cleanup of snapshots.
Foreach($vm in $vms){
    $snapshots = Get-VMSnapshot -VMName TestVM | Where-Object {$_.CreationTime -lt $time } | FT
    Write-Host "The following snapshots are remaining after cleanup"
    Write-Output $snapshots
    Write-Output $snapshots | Out-File $outfile -append
}