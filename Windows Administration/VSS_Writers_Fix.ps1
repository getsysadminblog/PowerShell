#################################################
#   Volume Snapshot Service Repair              #
#   Created by - Cameron Joyce                  #
#   Last Modified - Apr 27 2017                 #
#################################################
# This script is used to repair Microsoft VSS on servers that are failing backups.
 
# Set Location
sl "C:\windows\system32"
 
# Stop Services
If((Get-Service -name vss).Status -eq "Running"){
    Stop-Service -Name vss -force
    If(!((Get-Service -name vss).Status -eq "Stopped")){
        Write-Host = "VSS Service failed to stop. Stop manually and re-run script"
        Break
    }
}
If((Get-Service -name swprv).Status -eq "Running"){
    Stop-Service -Name swprv -force
    If(!((Get-Service -name vss).Status -eq "Stopped")){
        Write-Host = "Shadow Copy Provider Service failed to stop. Stop manually and re-run script"
        Break
    }
}
 
# Re-Register DLLs for VSS
regsvr32 /s ole32.dll
regsvr32 /s oleaut32.dll
regsvr32 /s vss_ps.dll
regsvr32 /s /i swprv.dll
regsvr32 /s /i eventcls.dll
regsvr32 /s es.dll
regsvr32 /s stdprov.dll
regsvr32 /s vssui.dll
regsvr32 /s msxml.dll
regsvr32 /s msxml3.dll
regsvr32 /s msxml4.dll
vssvc /register 
 
# Start Services
Start-Service vss
Start-Service swprv
If(!((Get-Service -name vss).Status -eq "Running")){
    Write-Host = "VSS Service failed to start. Start service manually"
}
If(!((Get-Service -name swprv).Status -eq "Running")){
    Write-Host = "Shadow Copy Provider Service failed to start. Start service manually"
}