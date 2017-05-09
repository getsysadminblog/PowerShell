#################################################################
#   Windows Server Backup                                       #
#   Created by - Cameron Joyce                                  #
#   Last Modified - May 2nd 2017                                #
#################################################################
# This script is used to do an on demand backup of a windows server (server 2008 or newer). 

# Variables
$date = (Get-Date).ToString('MM-dd-yyyy')
$time = (Get-Date).ToString('MM-dd-yyyy HH:mm:ss')
$hostname = $env:COMPUTERNAME
$backupserver = "your.server.fqdn"
$osversion = (Get-CimInstance Win32_OperatingSystem).version
$neterr = $false

# Setup folder and logfile.
If(Test-Connection -ComputerName $backupserver -count 1 -Quiet){
    # Try / Catch block for WMI errors. A client that passes Test-Connection may not have PSRemoting enabled and will error. This will handle that.
    Try{
        $ErrorActionPreference = "Stop"
        If(!(Test-Path "\\$backupserver\wsbackups\$hostname")){
            New-Item "\\$backupserver\wsbackups\$hostname" -Type Directory
        }
    }
    Catch [System.Management.Automation.Remoting.PSRemotingTransportException]{
        Write-Warning "Failed connection to backup server."
        $neterr = $true
        If($neterr -eq $true){
            Send-MailMessage -From "smtp@address.com" -To "rcpt@address.com" -Subject "$hostname failed scripted backup. Unable to connect to network storage." -Body "$hostname failed backup because it was unable to connect to '
            $backupserver. Please check the connections and try again." -SmtpServer "srvr.server.com"
        }
        Break
    }
    Finally{
        $ErrorActionPreference = "Continue"
    }
}

# Create Directories and logs.
If(!(Test-Path "\\$backupserver\wsbackups\$hostname\$Date")){
    New-Item "\\$backupserver\wsbackups\$hostname\$Date" -Type Directory
}
$logfile = "\\$backupserver\wsbackups\$hostname\$date\$hostname.$date.txt"

# Verify WSB is installed and load modules. If it is not installed, install it.
Import-Module ServerManager
$bkup = Get-WindowsFeature *backup*
# This if loop contains the commands for install on both 2008 - 2012 as well as server 2016.
If($bkup.InstallState -like "Available"){
    Write-Host "Installing windows server backup role."
    Write-Output "Installing windows server backup role." | Out-File $logfile -append
    If($osversion -like "6.3*" -or "10*"){
    Add-WindowsFeature -Name Windows-Server-Backup -Restart:$false
    }
    Else{Add-WindowsFeature -Name Backup-Features -IncludeAllSubFeature:$true -Restart:$false}
}
Else{
    Write-Host "Server backup is already installed."
    Write-Output "Server backup is already installed." | Out-File $logfile -append
}

# Execute Backup.
Write-Output "Starting Backup at $time" | Out-File $logfile -append
& cmd.exe /c "wbadmin start backup -backupTarget:\\$backupserver\wsbackups\$hostname\$date -allCritical -systemState -vssFull -quiet" | Out-File $logfile -Append
Write-Output "Backup completed at $time" | Out-File $logfile -append

# Look for backup errors.
$eventid4 = $false
$eventlist = Get-WinEvent -logname Microsoft-Windows-Backup | Where {$_.timecreated -gt (Get-Date).Addminutes(-5)} | Select Message
Foreach($line in $table){
    If($line -like "The backup operation has finished successfully."){
        $eventid4 = $true
    }
}

# Send success / failure email.
If($eventid4 -eq $true){
    Write-Host "Backup Success!"
    Send-MailMessage -From "$hostname@domain.com" -To "rcpt@domain.com" -Subject "$hostname has successfully backed up." -Body "Review attachment for backup log." -Attachments "$logfile" -SmtpServer "smtp.server.com"
}
ElseIf($eventid4 -eq $false){
    Write-Host "Backup Failed"
    Send-MailMessage -From "$hostname@domain.com" -To "rcpt@domain.com" -Subject "$hostname has failed backedup." -Body "Review attachment for backup log." -Attachments "$logfile" -SmtpServer "smtp.server.com"
}