<#
    Thanks to Windows OS Hub for the account control parser.
    http://woshub.com/decoding-ad-useraccountcontrol-value/
#>

Function decodeUserAccountControl ([int]$UAC)
{
$UACPropertyFlags = @(
"SCRIPT",
"ACCOUNTDISABLE",
"RESERVED",
"HOMEDIR_REQUIRED",
"LOCKOUT",
"PASSWD_NOTREQD",
"PASSWD_CANT_CHANGE",
"ENCRYPTED_TEXT_PWD_ALLOWED",
"TEMP_DUPLICATE_ACCOUNT",
"NORMAL_ACCOUNT",
"RESERVED",
"INTERDOMAIN_TRUST_ACCOUNT",
"WORKSTATION_TRUST_ACCOUNT",
"SERVER_TRUST_ACCOUNT",
"RESERVED",
"RESERVED",
"DONT_EXPIRE_PASSWORD",
"MNS_LOGON_ACCOUNT",
"SMARTCARD_REQUIRED",
"TRUSTED_FOR_DELEGATION",
"NOT_DELEGATED",
"USE_DES_KEY_ONLY",
"DONT_REQ_PREAUTH",
"PASSWORD_EXPIRED",
"TRUSTED_TO_AUTH_FOR_DELEGATION",
"RESERVED",
"PARTIAL_SECRETS_ACCOUNT"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
)
$Attributes = ""
1..($UACPropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2,$_)} | ForEach-Object {If ($Attributes.Length -EQ 0) {$Attributes = $UACPropertyFlags[$_]} Else {$Attributes = $Attributes + " | " + $UACPropertyFlags[$_]}}
Return $Attributes
}

Function Invoke-GPCheck (){
    $gp = gpresult.exe /scope COMPUTER /v
    foreach ($line in (1..($gp.Count - 1))){
        if ($gp[$line] -like "*ClearTextPassword*"){
            if ($gp[$line + 1] -like "*Computer Setting:  Not Enabled*"){
                Write-Output "Looks like Group Policy is set to save reverible passwords."
            }
            else{
                Write-Output "Group Policy is set correctly."
            }
        }
    }
}
Function Invoke-UserSearch (){
    Write-Output "`r`n`r`nThe following users may have revesible passwords:"
    $adUsers =  (([adsisearcher]"(&(objectCategory=User))").findall()).properties
    foreach ($user in $adusers) {
        $uacs = decodeUserAccountControl $user['useraccountcontrol'].Item(0)
        if ($uacs -like "*ENCRYPTED_TEXT_PWD_ALLOWED*"){
            Write-Output $user['samaccountname']
        }
    }
}

Function Invoke-ReversiblePasswordCheck(){
    Invoke-GPCheck
    Invoke-UserSearch
}