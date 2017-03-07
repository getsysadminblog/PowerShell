#####################################################
#   Clear ADSI Attribute from all users.            #
#   Created by - Cameron Joyce                      #
#   Last Modified - Mar 05 2017                     #
#####################################################
# This script will remove a specified ADSI attribute from all users in active Directory.

# Variables
$users = Get-ADUser -Filter *
$attrib = Read-Host "Which ADSI Attribute would you like to set null?"

# Foreach user in AD, set all attributes to $null
foreach($user in $users){
    $ldapDN = "LDAP://" + $user.distinguishedName
    $adUser = New-Object DirectoryServices.DirectoryEntry $ldapDN
    $adUser.PutEx(1, "$attrib", $null)
    $adUser.SetInfo()
}