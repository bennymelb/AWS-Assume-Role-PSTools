### This is a simple powershell script to assume a aws iam role
### This script required you to have AWS tools for windows powershell pre installed and you have configured it with a default access key/sercet key or a named profile

Param (

    # MFA code from the MFA device
    [string]$mfacode,

    # The IAM role you want to assume
    [string]$role,

    # The aws account id of the role you want to assume
    [string]$awsaccountid, 

    # AWS profile (optional)
    [string]$profilename,

    # Use MFA or not (optional), default is true
    [string]$requiremfa="true",

    # Session name for the assume role
    [string]$sessionname,

    # Username of the user
    [string]$username

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

# Generate a random session name if user didn't supply one
if (!$sessionname){
    $sessionname = $(New-Guid).ToString()
}

# Prompt user to enter necessary detail
if ( (!$role) -and (!$awsaccountid) ) {
    $role = Read-Host "Please enter the name of the role you wanted to assume"
    $awsaccountid = Read-Host "Please enter the arn of the role you want to assume, leave this blank if the role you want to assume is in the same aws account"
}

# Prompt user to enter the mfa code if they didn't supply one when calling this script
if ( ($requiremfa -eq "true") -and (!$mfacode) ) {
    if (!$username) {
        $username = Read-Host "Please enter your username, you can leave this blank if you want the script retrieve your username from access key"
    }
    $mfacode = Read-Host "Please enter your mfa code"
}

if (!$profilename){
    
    
    # Get the MFA arn from the username if mfa required is true
    if ($requiremfa -eq "true")
    {
        # Get username from access key
        if (!$username) {
            $username = $(Get-IAMUser -ErrorVariable err).UserName
            if ($err) {
                write-host $err
                write-host "Error!!! failed to get username from your access key"
                exit 1
            }
        }
        $mfaarn = $(Get-IAMMFADevice -UserName $username -ErrorVariable err).SerialNumber
        if ($err){  
            write-host $err
            write-host "Error!!! failed to get the mfa arn from the username $username"
            exit 1
        }
    }    
    
    # construct the role arn
    if (!$awsaccountid){ 
       $rolearn = $(Get-IAMRole -RoleName $role -ErrorVariable err).Arn
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get the role $role arn"
            exit 1
        }
    }
    else {
        $rolearn = "arn:aws:iam::" + $awsaccountid + ":role/" + $role
    }    

    # assume the role and get the temp credential
    if ($requiremfa -eq "true") {
        $RoleCred = $(Use-STSRole -RoleArn $rolearn -RoleSessionName $sessionname -TokenCode $mfacode -SerialNumber $mfaarn -ErrorVariable err).Credentials
        if ($err) {
            Write-Host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }
    else {
        $RoleCred = $(Use-STSRole -RoleArn $rolearn -RoleSessionName $sessionname -ErrorVariable err).Credentials
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
        if (!$username) {
            $username = $(Get-IAMUser -profilename $profilename -ErrorVariable err).UserName
            if ($err) {
                write-host $err
                write-host "Error!!! failed to get username from your access key"
                exit 1
            }
        }
        $mfaarn = $(Get-IAMMFADevice -profilename $profilename -UserName $username -ErrorVariable err).SerialNumber
        if ($err){
            write-host $err
            write-host "Error!!! failed to get the mfa arn from the username $username"
            exit 1
        }
    }   
    
    # construct the role arn
    if (!$awsaccountid){
        $rolearn = $(Get-IAMRole -profilename $profilename -RoleName $role -ErrorVariable err).Arn
        if ($err) {
            write-host $err
            write-host "Error!!! failed to get the role $role arn"
            exit 1
        }    
    }
    else {
        $rolearn = "arn:aws:iam::" + $awsaccountid + ":role/" + $role
    }    

    # assume the role and get the temp credential
    if ($requiremfa -eq "true") {
        $RoleCred = $(Use-STSRole -ProfileName $profilename -RoleArn $rolearn -RoleSessionName $sessionname -TokenCode $mfacode -SerialNumber $mfaarn -ErrorVariable err).Credentials
        if ($err) {
            write-host $err
            write-Host "Error!!! failed to assume the role $role"
            exit 1
        }
    }
    else {
        $RoleCred = $(Use-STSRole -ProfileName $profilename -RoleArn $rolearn -RoleSessionName $sessionname -ErrorVariable err).Credentials
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

if (!$awsaccountid){
    write-host "You've assumed the role $role, your session name is $sessionname" -ForegroundColor Green
}
else {
    write-host "You've assumed the role $role in account $awsaccountid, your session name is $sessionname" -ForegroundColor Green
}
Read-Host "Press enter to contine the session"