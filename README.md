# What is this?
This is a simple powershell script helps you to assume a role with an MFA token

# Why do we need it?
Most likely for our AWS user account to assume a role it required MFA and there is no easy way to do it in a powershell session, so I made this script to interact with user to acquire necessary information to assume a role and store its credential into the environmental variable.

# Prerequisite
This script requires the following
- [AWS Tools for powershell](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html)
- [A default profile or a named profile](https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html)

# How to use this script?
To use this script, you just need to download assume-role.ps1 and call the script.

e.g.

Assume you've downloaded assume-role.ps1 in C:\temp
```
PS C:\temp> .\assume-role.ps1
Please enter the name of the role you wanted to assume: myiamrole
Please enter the arn of the role you want to assume, leave this blank if the role you want to assume is in the same aws account: 123456789
Please enter your username, you can leave this blank if you want the script retrieve your username from access key: myusername
Please enter your mfa code: 123456
```

If you wanted to use a named profile, you can
```
PS C:\temp> .\assume-role.ps1 -profilename myprofile
Please enter the name of the role you wanted to assume: myiamrole
Please enter the arn of the role you want to assume, leave this blank if the role you want to assume is in the same aws account:
Please enter your username, you can leave this blank if you want the script retrieve your username from access key:
Please enter your mfa code: 123456
```

If you dont want to wait for the script to ask you for the IAM role name and MFA code, you can
```
PS C:\temp> .\assume-role.ps1 -profilename myprofile -role myiamrole -mfacode 123456
```

If you want to assume a role in a different aws account, you can
```
PS C:\temp> .\assume-role.ps1 -role myiamrole -awsaccountid 123456789 
```

If MFA is required but your access key does not have permission to retrieve the username, you will need to supply it
```
PS C:\temp> .\assume-role.ps1 -role myiamrole -awsaccountid 123456789 -username myusername
``` 

# List of parameter you can pass into this script
- mfacode
- role
- awsaccountid
- profilename
- requiremfa
- sessionname
- username

# To verify you've assumed the role
Issue the Get-STSCallerIdentity command, you should see it returns the account name and the arn of the role you've assumed