#####################################################
#   Disable ActiveSync for all users except Group   #
#   Created by - Cameron Joyce                      #
#   Last Modified - Feb 24 2017                     #
#####################################################
# This script will disable ActiveSync in Exchange for all users except those in a specified security group.

# Import Exchange Modules
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

# Variables
$AsMemeber = @(Get-DistributionGroupMember -Identity 'ActiveSync Users' | Select Name) # Insert all users from the ActiveSync Users group into an array.
$mailboxes = Get-Mailbox -ResultSize Unlimited # Get all Mailboxes in the exchange Orginization.

# For each mailbox check to see if the mailbox user is a member of the ActiveSync users group, if so enable OWA and AS. If not, disable it. 
Foreach($Mailbox in $Mailboxes){
    $Ismember = $false # Set the variable to the default of off
    $Name = $mailbox.Name # Convert the property to a string value.
    If($AsMemeber -like "*$name*"){ # If the Name of the mailbox is found in the array of ActiveSync Users, set the variable from $false to $true.
        $Ismember = $true
    }
    If($ismember){ # If the member is part of the Array do the following
        Write-Host "$name is an ActiveSync user and is being enabled"
        Set-CASMailbox $MName –ActiveSyncEnabled $true
        $astatus = Get-CASMailbox $Name | Select-Object Name, ActiveSyncEnabled
        if($astatus -like "False"){
            Write-Host "Failure occured setting ActiveSync policy on the following mailbox"
            Write-Output $astatus
        }
        Set-CASMailbox $Name -OWAforDevicesEnabled $true
        $ostatus = Get-CASMailbox $Name| Select-Object Name, OWAforDevicesEnabled
        if($ostatus -like "False"){
            Write-Host "Failure occured setting OWA for Devices policy on the following mailbox"
            Write-Output $ostatus
        }
    }
    Else{ # If the mailbox is not a member of the Array do the following.
        Write-Host "$name is not an ActiveSync user and is being disabled"
        Set-CASMailbox $Name –ActiveSyncEnabled $false
        Set-CASMailbox $Name –OWAforDevicesEnabled $false
    }
}