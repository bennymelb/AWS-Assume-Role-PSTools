### This is a simple powershell script to assume a aws iam role
### This script required you to have AWS tools for windows powershell pre installed and you have configured it with a default access key/sercet key or a named profile

Param (

    # MFA code from the MFA device
    [string]$mfacode,

    # The IAM role you want to assume, use this if the iam role is in the same aws account
    [string]$role,

    # The arn of the IAM role you want to assume, use this if the iam role is in a different aws account
    [string]$rolearn, 

    # AWS profile (optional)
    [string]$profilename,

    # Use MFA or not (optional), default is true
    [string]$requiremfa="true"

)

# Check if AWS Tools for powershell is installed
try {
    Get-AWSPowerShellVersion
}
catch {
    write-host $_.Exception.Message
    write-host "Error!!! AWS Tools for powershell is not installed on this system"
    exit 1
}

# Prompt user to enter the role name or arn if they didn't supply one
if ( (!$role) -and (!$rolearn) ) {
    $sw = Read-Host "Are you supplying just the role name or the full arn [ role | rolearn ]"
    if ($sw -eq "role") {
        $role = Read-Host "Please enter the name of the role you wanted to assume"
    }
    elseif ($sw -eq "rolearn") {
        $rolearn = Read-Host "Please enter the arn of the role you want to assume"
    }
    else {
        Read-Host "Invalid input detected, press any button to exit"
        exit 1
    }
}

# Prompt user to enter the mfa code if they didn't supply one when calling this script
if ( ($requiremfa -eq "true") -and (!$mfacode) ) {
    $mfacode = Read-Host "Please enter your mfa code"
}

if (!$profilename){
    
    
    # Get the MFA arn from the username if mfa required is true
    if ($requiremfa -eq "true")
    {
        # Get username from access key
        $username = $(Get-IAMUser -ErrorVariable err).UserName
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get username from your access key"
            exit 1
        }
        $mfaarn = $(Get-IAMMFADevice -UserName $username -ErrorVariable err).SerialNumber
        if ($err){  
            write-host $err
            write-host "Error!!! failed to get the mfa arn from the username $username"
            exit 1
        }
    }    
    
    # Get the role ARN from the role name
    if (!$rolearn){ 
       $rolearn = $(Get-IAMRole -RoleName $role -ErrorVariable err).Arn
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get the role $role arn"
            exit 1
        }
    }    

    # assume the role and get the temp credential
    if ($requiremfa -eq "true") {
        $RoleCred = $(Use-STSRole -RoleArn $rolearn -RoleSessionName $(New-Guid).ToString() -TokenCode $mfacode -SerialNumber $mfaarn -ErrorVariable err).Credentials
        if ($err) {
            Write-Host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }
    else {
        $RoleCred = $(Use-STSRole -RoleArn $rolearn -RoleSessionName $(New-Guid).ToString() -ErrorVariable err).Credentials
        if ($err) {
            Write-Host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }    
}
else {
    
    # Get the MFA arn from the username
    if ($requiremfa -eq "true") {
        # Get username from access key
        $username = $(Get-IAMUser -profilename $profilename -ErrorVariable err).UserName
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get username from your access key"
            exit 1
        }
        $mfaarn = $(Get-IAMMFADevice -profilename $profilename -UserName $username -ErrorVariable err).SerialNumber
        if ($err){
            write-host $err
            write-host "Error!!! failed to get the mfa arn from the username $username"
            exit 1
        }
    }   
    
    # Get the role ARN from the role name
    if (!$rolearn){
        $rolearn = $(Get-IAMRole -profilename $profilename -RoleName $role -ErrorVariable err).Arn
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get the role $role arn"
            exit 1
        }    
    }

    # assume the role and get the temp credential
    if ($requiremfa -eq "true") {
        $RoleCred = $(Use-STSRole -ProfileName $profilename -RoleArn $rolearn -RoleSessionName $(New-Guid).ToString() -TokenCode $mfacode -SerialNumber $mfaarn -ErrorVariable err).Credentials
        if ($err) {
            write-host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }
    else {
        $RoleCred = $(Use-STSRole -ProfileName $profilename -RoleArn $rolearn -RoleSessionName $(New-Guid).ToString() -ErrorVariable err).Credentials
        if ($err) {
            write-host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }
}

# store the credential into environment variable
$env:AWS_ACCESS_KEY_ID = $RoleCred.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $RoleCred.SecretAccessKey
$env:AWS_SESSION_TOKEN = $RoleCred.SessionToken

write-host "You've assumed the role $role" -ForegroundColor Green
Read-Host "Press enter to contine the session"