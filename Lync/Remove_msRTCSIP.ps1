#####################################################
#   Remove msRTCSIP Attributes from all users.      #
#   Created by - Cameron Joyce                      #
#   Last Modified - Mar 05 2017                     #
#####################################################
# This script will remove the msRTCSIP attributes from all users in ActiveDirectory. This is meant to be used in an
# Office 365 migration in which you have an on premise lync server, however do not plan to do a hybrid migration to
# migrate users. 
 
# Variables
$users = Get-ADUser -Filter *
 
# Foreach user in AD, set all attributes to $null
foreach($user in $users){
    $ldapDN = "LDAP://" + $user.distinguishedName
    $adUser = New-Object DirectoryServices.DirectoryEntry $ldapDN
    $adUser.PutEx(1, "msRTCSIP–DeploymentLocator", $null)
    $adUser.PutEx(1, "msRTCSIP-FederationEnabled", $null)
    $adUser.PutEx(1, "msRTCSIP-InternetAccessEnabled", $null)
    $adUser.PutEx(1, "msRTCSIP-Line", $null)
    $adUser.PutEx(1, "msRTCSIP-OptionFlag", $null)
    $adUser.PutEx(1, "msRTCSIP-PrimaryHomeServer", $null)
    $adUser.PutEx(1, "msRTCSIP–PrimaryUserAddress", $null)
    $adUser.PutEx(1, "msRTCSIP–UserEnabled", $null)
    $adUser.PutEx(1, "msRTCSIP-UserPolicies", $null)
    $adUser.SetInfo()
}