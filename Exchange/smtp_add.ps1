#################################################
#   Add new SMTP address to all mailboxes.      #
#   Created by - Cameron Joyce                  #
#   Last Modified - Jun 04 2017                 #
#################################################
# This script will add a new SMTP address for each mailbox on a specificed Exchange server.
# This script must be run from the Exchange Management Shell for Exchange 2010 - 2016

$mailboxes = Get-Mailbox -server servername

Foreach ($mailbox in $mailboxes){
    $name = $mailbox.alias
    Set-Mailbox "$name" -EmailAddresses @{add="$name@domain.com"}
}