## AWS MFA IAM Policy

### Description
The following policy forces IAM users to enable MFA before they can access any AWS resources via the Console or CLI.

### Policy
```
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BlockMostAccessUnlessSignedInWithMFA",
            "Effect": "Deny",
            "NotAction": [
                "iam:ChangePassword",
                "iam:CreateVirtualMFADevice",
                "iam:DeleteVirtualMFADevice",
                "iam:ListVirtualMFADevices",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:ListAccountAliases",
                "iam:ListUsers",
                "iam:ListSSHPublicKeys",
                "iam:ListAccessKeys",
                "iam:ListServiceSpecificCredentials",
                "iam:ListMFADevices",
                "iam:GetAccountSummary",
                "sts:GetSessionToken"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
```

### CLI Long-term Credentials
IAM users need to request a session token before they can access AWS resources via AWS CLI. A session token is valid for 12 hours.

#### Request Session Token
Follow the steps outlined below to request a session token:

1. Log in to AWS CLI with your IAM access key and secret.
2. Enter the following command and record the SerialNumber of your MFA device:
```
aws iam list-mfa-devices
```
3. Enter the following command, replacing the **SerialNumber** and **TokenCode** values with the serial number obtained from running the previous command and a token from your Google Authenticator app, respectively. 
```
aws sts get-session-token --serial-number SerialNumber --token-code TokenCode
```
4. Export the access key, secret sey, and session token obtained from the previous command to environmental variables:
```
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
export AWS_SESSION_TOKEN=xxxxxxxxxxxxx
```
5. Clear the envrionmental variables before requesting a new session token:
```
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
```
