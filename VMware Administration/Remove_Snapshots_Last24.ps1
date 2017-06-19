#################################################################
#   Remove all snapshots from vSphere from the last 24 Hours    #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Jun 19 2017                                 #
#################################################################
# This script uses PowerCLI to remove all snapshots from virtual machines that are 24 hours old. 

# Load all VMware Modules, and set PowerCLI config.
Get-Module -ListAvailable VM* | Import-Module

# Connect to vSphere vCenter Server.
Try{
    connect-viserver -server your.vmware.server -user administrator@vsphere.local -Password Password
}
Catch{
    Write-Host "Failed Connecting to VSphere Server."
    Send-MailMessage -From "" -To "server@domain.com" -Subject "Unable to Connect to VSphere to clean snapshots" -Body `
    "The powershell script is unable to connect to host your.vmware.server. Please investigate." -SmtpServer "smtp.server.com"
    Break
}

# Variables
$date = get-date -f MMddyyyy
$logpath = "C:\Scripts\Script_Logs"

# Verify the log folder exists.
If(!(Test-Path $logpath)){
    Write-Host "Log path not found, creating folder."
    New-Item $logpath -Type Directory
}

# Get all snapshots older than 24 hours, remove them.
If((get-snapshot -vm *) -ne $null){
    $snapshotlist = get-snapshot -vm * | select VM, Name, SizeMB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}    
    Write-Host "Current Snapshots in Dallas vSphere"
    Write-Output $snapshotlist
    Write-Output "Snapshots existing before cleanup" | Out-File $logpath\Snapshots_$date.txt -Append
    Write-Output $snapshotlist | Out-File $logpath\Snapshots_$date.txt -Append
}

# Check to make sure that all snapshots have been cleaned up.
If((get-snapshot -vm *) -ne $null){
    get-snapshot -vm * | Where-Object {$_.Created -lt (Get-Date).AddDays(-1)} | Remove-Snapshot -Confirm:$false
    $snapshotlist = get-snapshot -vm * | select VM, Name, SizeMB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}
    Write-Host "Current Snapshots in Dallas vSphere after cleanup"
    Write-Output $snapshotlist
    Write-Output "Snapshots existing after cleanup" | Out-File $logpath\Snapshots_$date.txt -Append
    Write-Output $snapshotlist | Out-File $logpath\Snapshots_$date.txt -Append
}
Else{
    Write-Output "No Snapshots to clean up." | Out-File $logpath\Snapshots_$date.txt -Append
}

# Send snapshot log to email.
$emailbody = (Get-Content $logpath\Snapshots_$date.txt | Out-String)
Send-MailMessage -From "server@domain.com" -To "user@domain.com.com" -Subject "Daily vSphere snapshot cleanup report" -Body $emailbody -SmtpServer "smtp.server.com"


# Exit VIM server session.
Try{
    disconnect-viserver -server your.vmware.server -Confirm:$false
}
Catch{
    Write-Host "Failed disconnecting from VSphere."
    Send-MailMessage -From "server@domain.com" -To "user@domain.com" -Subject "Disconnection from VSphere Failed" -Body `
    "The powershell script is unable to disconnect from VSphere. Please manually disconnect" -SmtpServer "smtp.server.com"
}

# Cleanup Snapshot logs older than 30 days.
gci -path $logpath -Recurse -Force | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-30)} | Remove-Item -Force