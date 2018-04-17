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
Please enter the name of the role you wanted to assume: <name of the iam role you wanted to assume>
Please enter your mfa code: <your mfa code>
```

If you wanted to use a named profile, you can
```
PS C:\temp> .\assume-role.ps1 -profile <your profile>
Please enter the name of the role you wanted to assume: <name of the iam role you wanted to assume>
Please enter your mfa code: <your mfa code>
```

Or If you dont want to wait for the script to ask you for the IAM role name and MFA code, you can
```
PS C:\temp> .\assume-role.ps1 -profile <your profile> -role <name of the IAM role you want to assume> -mfacode <your mfa code>
```

# To verify you've assumed the role
Issue the Get-IAMUser command, if you see an error return said "Must specify userName when calling with non-User credentials" This mean you are using the assumed role made the Get-IAMUser call.