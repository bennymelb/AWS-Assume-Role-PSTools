# What is this?
This is a simple powershell script helps you to assume a role with an MFA token

# Why do we need it?
Most likely for our AWS user account to assume a role it required MFA and there is no easy way to do it in a powershell session, so I made this script to interact with user to acquire necessary information to assume a role and store its credential into the environmental variable.

# Prerequisite
This script requires the following
- [AWS Tools for powershell](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html)
- [A default profile or a named profile](https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html)

# How to use this script
To use this script, you just need to download assume-role.ps1 and call the script.

e.g.

Assume you've download assume-role.ps1 in C:\temp
```
PS C:\temp> .\assume-role.ps1
```

If you wanted to use a named profile, you can
```
PS C:\temp> .\assume-role.ps1 -profile <your profile>
```
