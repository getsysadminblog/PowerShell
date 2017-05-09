#################################################################
#   Remove all snapshots from vSphere from the last 24 Hours    #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Oct 17 2016                                 #
#################################################################
# This script uses PowerCLI to remove all snapshots from virtual machines that are 24 hours old. 

# Load all VMware Modules, and set PowerCLI config.
Get-Module -ListAvailable VM* | Import-Module

# Connect to vSphere vCenter Server.
Try{
    connect-viserver -server "server.name.here" -user username -Password password
}
Catch{
    Write-Host "Failed Connecting to vCenter Server."
    Send-MailMessage -From "vmware@company.com" -To "you@company.com" -Subject "Unable to Connect to vCenter to clean snapshots" -Body "The powershell script is unable to connect to host Hostname. Please investigate." -SmtpServer "smtp.company.com"
    Break
}

# Variables
$snapshotlist = get-snapshot -vm * | select VM, Name, SizeMB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}
$date = get-date -f MMddyyyy

# Get all snapshots older than 24 hours, remove them.
If((get-snapshot -vm *) -ne $null){
    Write-Host "Current Snapshots in Dallas vSphere"
    Write-Output $snapshotlist
    Write-Output "Snapshots existing before cleanup" | Out-File E:\Scripts\Script_Logs\Snapshots_$date.txt -Append
    Write-Output $snapshotlist | Out-File E:\Scripts\Script_Logs\Snapshots_$date.txt -Append
    get-snapshot -vm * | Where-Object {$_.Created -lt (Get-Date).AddDays(-1)} | Remove-Snapshot -Confirm:$false
    Write-Host "Current Snapshots in Dallas vSphere after cleanup"
    Write-Output (get-snapshot -vm * | select VM, Name, SizeMB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}})
    Write-Output "Snapshots existing after cleanup" | Out-File E:\Scripts\Script_Logs\Snapshots_$date.txt -Append
    Write-Output (get-snapshot -vm * | select VM, Name, SizeMB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}) | Out-File E:\Scripts\Script_Logs\Snapshots_$date.txt -Append
}
Else{
    Write-Output "No Snapshots to clean up." | Out-File E:\Scripts\Script_Logs\Snapshots_$date.txt -Append
}

# Send snapshot log to email.
$emailbody = (Get-Content E:\Scripts\Script_Logs\Snapshots_$date.txt | Out-String)
Send-MailMessage -From "vmware@company.com" -To "you@company.com" -Subject "Daily vSphere snapshot cleanup report" -Body $emailbody -SmtpServer "smtp.company.com"

# Exit VIM server session.
Try{
    disconnect-viserver -server Hostname -Confirm:$false
}
Catch{
    Write-Host "Failed disconnecting from vCenter."
    Send-MailMessage -From "vmware@company.com" -To "you@company.com" -Subject "Disconnection from vCenter Failed" -Body "The powershell script is unable to disconnect from vCenter. Please manually disconnect" -SmtpServer "smtp.company.com"
}

# Cleanup Snapshot logs older than 30 days.
gci -path E:\Scripts\Script_Logs -Recurse -Force | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -gt (Get-Date).AddDays(-30)} | Remove-Item -Force