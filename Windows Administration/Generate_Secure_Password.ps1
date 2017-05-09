#################################################################
#   Generate AES Secured Password for Scriptng                  #
#   Created by - Cameron Joyce                                  #
#   Last Modified - Dec 25 2016                                 #
#################################################################
# This script is used to generate a secured AES key and password string for use with other automation. 

# Variables
$Key = New-Object Byte[] 32   # AES Key. Sizes for byte count are 16 (128) 24 (192) 32 (256).
$UnSecPass = Read-Host "Enter Password you wish to use"
$PassName = Read-Host "Enter a filename for the password file."
$SecPass = "$UnSecPass" | ConvertTo-SecureString -AsPlainText -Force
$PasswordFile = "$env:Userprofile\Downloads\$PassName.txt" # OutFile Path for encrypted password.
$KeyFile = "$env:Userprofile\Downloads\$PassName.AES.key" # Path to Generated AES Key.

# Create Random AES Key in length specified in $Key variable.
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)

# Export Generated Key to File
$Key | out-file $KeyFile

# Combine Plaintext password with AES key to generate secure Password.
$SecPass | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile